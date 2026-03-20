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
