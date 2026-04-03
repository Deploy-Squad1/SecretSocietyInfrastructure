locals {
  policy_arns = {
    ecr_push = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  }
}

# Data (AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ECR repositories
module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "core-service",
    "frontend-service",
    "email-service",
    "map-service",
    "voting-service",
    "nginx-gateway-fabric",
    "nginx-gateway-nginx"
  ]
}

# S3 bucket (media)
module "s3" {
  source = "../../modules/s3"

  bucket_name     = "secret-society-media-ds-stage"
  allowed_origins = ["http://localhost:5173"]
}

# Secrets Manager
data "aws_secretsmanager_secret" "map_service" {
  name = "secret-society/map-service"
}

module "secrets" {
  source = "../../modules/secrets"

  environment               = "stage"
  create_map_service_secret = false
}

# IAM
module "iam" {
  source = "../../modules/iam"

  env            = "stage"
  user_name      = "github-actions"
  team_user_arns = var.team_user_arns
  # Attach only the policies this user actually needs
  policy_arns = [
    local.policy_arns.ecr_push,
  ]

  service_users = {
    "map-service" = {
      bucket_name = "secret-society-media-ds-stage"
      secret_arn  = data.aws_secretsmanager_secret.map_service.arn
    }
  }

  eks_cluster_arn = module.eks.cluster_arn
}

# VPC
module "vpc" {
  source = "../../modules/vpc"

  name = "secret-society-stage"
  cidr = "10.10.0.0/16"
}

# Security groups
module "security" {
  source = "../../modules/security"

  name     = "secret-society-stage"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.cidr
}

# RDS
module "rds" {
  source = "../../modules/rds"

  name               = "secret-society-stage-db"
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.rds_sg_id]

  db_name  = "secretsociety"
  username = "app_user"

  instance_class = "db.t3.micro"

  skip_final_snapshot     = false
  deletion_protection     = false
  backup_retention_period = 1
}

# EKS
module "eks" {
  source = "../../modules/eks"

  name               = "secret-society-stage"
  kubernetes_version = "1.35"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = ["t3.small"]
  node_min_size       = 1
  node_max_size       = 3
  node_desired_size   = 2

  access_entries = {
    admin = {
      principal_arn = module.iam.eks_admin_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    admin_host = {
      principal_arn = "arn:aws:iam::485141927994:role/admin-ssm-role-stage"

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    terraform = {
      principal_arn = "arn:aws:iam::485141927994:role/TerraformDeployRole"

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    environment = "stage"
  }
}

# Admin host (SSM bastion)
module "admin_host" {
  source = "../../modules/admin_host"

  env           = "stage"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id         = module.vpc.private_subnet_ids[0]
  security_group_id = module.security.admin_host_sg_id

  eks_cluster_arn = module.eks.cluster_arn
}

module "ec2" {
  source = "../../modules/ec2"

  env           = "stage"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security.jenkins_sg_id
}

module "gateway" {
  source = "../../modules/gateway"

  gateway_image_repository = "ghcr.io/nginxinc/nginx-gateway-fabric"
  gateway_image_tag        = "latest"
}

resource "aws_security_group_rule" "admin_host_to_eks_api" {
  description              = "Allow admin host to access EKS API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = module.security.admin_host_sg_id
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

resource "aws_security_group_rule" "lb_to_nodes_https" {
  description       = "Allow LoadBalancer to reach EKS nodes on 443"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = module.eks.node_security_group_id

  # temporary (later replace to source_security_group_id = <lb_sg_id>)
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_to_eks_api" {
  description              = "Allow Jenkins EC2 to access EKS API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = module.security.jenkins_sg_id
}

resource "aws_security_group_rule" "node_to_node_all" {
  description              = "Allow all traffic between EKS nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.eks.node_security_group_id
}
