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

# public subnets for internet-facing resources
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

# route table for public subnets
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

# private route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# security group for interface VPC endpoints
resource "aws_security_group" "vpce" {
  name        = "${var.name}-vpce-sg"
  description = "Security group for interface VPC endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTPS from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-vpce-sg"
  }
}

# gateway endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.name}-s3-endpoint"
  }
}

# interface endpoint for ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-ecr-api-endpoint"
  }
}

# interface endpoint for ECR Docker registry
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-ecr-dkr-endpoint"
  }
}

# internet endpoint for EC2 API
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-ec2-endpoint"
  }
}

# interface endpoint for STS
resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-sts-endpoint"
  }
}
# interface endpoints for SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "${var.name}-ec2messages-endpoint"
  }
}
