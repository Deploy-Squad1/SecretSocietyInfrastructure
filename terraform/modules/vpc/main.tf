resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

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

# private subnets (for RDS + EKS)
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = "${var.name}-${each.key}"
  }
}

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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-igw"
  }
}

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

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}