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

  repositories = var.ecr_repositories
}

# S3 bucket (media)
module "s3" {
  source = "../../modules/s3"

  bucket_name     = var.media_bucket_name
  allowed_origins = var.media_allowed_origins
}

# Secrets Manager
data "aws_secretsmanager_secret" "map_service" {
  name = "secret-society/map-service"
}

module "secrets" {
  source = "../../modules/secrets"

  environment               = var.environment
  create_map_service_secret = false

  db_user = var.db_user
  db_host = module.rds.endpoint
  db_name = var.db_name
  db_port = var.db_port
}

# IAM
module "iam" {
  source = "../../modules/iam"

  env            = var.environment
  user_name      = "github-actions"
  team_user_arns = var.team_user_arns
  # Attach only the policies this user actually needs
  policy_arns = [
    local.policy_arns.ecr_push,
  ]

  service_users = {
    "map-service" = {
      bucket_name = var.media_bucket_name
      secret_arn  = data.aws_secretsmanager_secret.map_service.arn
    }
  }

  eks_cluster_arn = module.eks.cluster_arn
}

# VPC
module "vpc" {
  source = "../../modules/vpc"

  name = var.vpc_name
  cidr = var.vpc_cidr
}

# Security groups
module "security" {
  source = "../../modules/security"

  name     = "secret-society-${var.environment}"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.cidr
}

# RDS
module "rds" {
  source = "../../modules/rds"

  name               = var.rds_name
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security.rds_sg_id]

  db_name  = var.db_name
  username = var.db_user
  password = module.secrets.db_password

  instance_class = var.rds_instance_class

  skip_final_snapshot     = var.rds_skip_final_snapshot
  deletion_protection     = var.rds_deletion_protection
  backup_retention_period = var.rds_backup_retention_period
}

# EKS
module "eks" {
  source = "../../modules/eks"

  name               = var.eks_name
  kubernetes_version = var.eks_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size

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
    environment = var.environment
  }
}

# Admin host (SSM bastion)
module "admin_host" {
  source = "../../modules/admin_host"

  env           = var.environment
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.admin_instance_type

  subnet_id         = module.vpc.private_subnet_ids[0]
  security_group_id = module.security.admin_host_sg_id

  eks_cluster_arn = module.eks.cluster_arn
}

# EC2
module "ec2" {
  source = "../../modules/ec2"

  env           = var.environment
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.jenkins_instance_type

  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security.jenkins_sg_id
}

# Gateway
module "gateway" {
  source = "../../modules/gateway"

  gateway_hostname = var.app_domain
  app_namespace    = "secret-society-${var.environment}"
}

# Route53 hosted zone
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Environment = var.environment
  }
}

# DNS
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.app_domain
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}

# TLS
module "cert_manager" {
  source = "../../modules/cert_manager"

  app_namespace = "secret-society-${var.environment}"
  app_domain    = var.app_domain
}

# Monitoring
module "splunk" {
  source = "../../modules/splunk"

  environment = var.environment
  namespace   = "splunk"

  splunk_hec_endpoint = var.splunk_hec_endpoint
  splunk_hec_token    = var.splunk_hec_token
  splunk_index        = "main"

  splunk_observability_realm        = var.splunk_observability_realm
  splunk_observability_access_token = var.splunk_observability_access_token

  cluster_name = module.eks.cluster_name
}

# Metrics
module "metrics_server" {
  source = "../../modules/metrics-server"

  namespace         = "kube-system"
  helm_release_name = "metrics-server"
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
