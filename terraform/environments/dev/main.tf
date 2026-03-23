locals {
  policy_arns = {
    ecr_push = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "core-service",
    "frontend-service",
    "email-service",
    "map-service",
    "voting-service"
  ]
}

module "s3" {
  source = "../../modules/s3"

  bucket_name     = "secret-society-media-ds"
  allowed_origins = ["http://localhost:5173"]
}

module "secrets" {
  source = "../../modules/secrets"

  environment = "dev"
}

module "iam" {
  source = "../../modules/iam"

  user_name = "github-actions"
  # Attach only the policies this user actually needs
  policy_arns = [
    local.policy_arns.ecr_push,
  ]

  service_users = {
    "map-service" = {
      bucket_name = "secret-society-media-ds"
      secret_arn  = module.secrets.map_service_secret_arn
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name       = "secret-society-dev"
  cidr       = "10.0.0.0/16"
  aws_region = "eu-north-1"
}

module "security" {
  source = "../../modules/security"

  name     = "secret-society-dev"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.cidr
}

module "rds" {
  source = "../../modules/rds"

  name               = "secret-society-dev-db"
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.rds_sg_id]

  db_name  = "secret_society"
  username = "app_user"

  instance_class = "db.t3.micro"

  skip_final_snapshot = false
  deletion_protection = false

  backup_retention_period = 1
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "ec2" {
  source = "../../modules/ec2"

  env               = "dev"
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.small"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security.jenkins_sg_id
}

module "eks" {
  source = "../../modules/eks"

  name               = "secret-society-dev"
  kubernetes_version = "1.35"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.medium"]
  node_min_size       = 1
  node_max_size       = 3
  node_desired_size   = 2

  access_entries = {}

  tags = {
    environment = "dev"
  }
}

resource "aws_security_group_rule" "eks_to_rds" {
  description              = "Allow PostgreSQL access from EKS nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.security.rds_sg_id
  source_security_group_id = module.eks.node_security_group_id
}
