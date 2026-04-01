# VPC (base network)
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# AZs with subnet definitions
data "aws_availability_zones" "available" {}

locals {
  private_subnets = {
    private-a = {
      cidr_block = cidrsubnet(var.cidr, 4, 0)
      az         = data.aws_availability_zones.available.names[0]
    }
    private-b = {
      cidr_block = cidrsubnet(var.cidr, 4, 1)
      az         = data.aws_availability_zones.available.names[1]
    }
  }
  public_subnets = {
    public-a = {
      cidr_block = cidrsubnet(var.cidr, 4, 2)
      az         = data.aws_availability_zones.available.names[0]
    }
    public-b = {
      cidr_block = cidrsubnet(var.cidr, 4, 3)
      az         = data.aws_availability_zones.available.names[1]
    }
  }
}

# Private subnets (for RDS + EKS)
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

# Public subnets (NAT, ALB, EC2)
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

# Internet Gateway (public internet access)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Public route table (IGW route)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

# Associate public subnets with public RT
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public-a"].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Private route table (uses NAT for internet)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

# Route private traffic to NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnets with private RT
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
