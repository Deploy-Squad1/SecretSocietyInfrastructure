locals {
  # All available managed policies — add new entries here as needed
  policy_arns = {
    ecr_push     = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    s3_read_only = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }
}

module "ecr" {
  source = "./modules/ecr"

  repositories = [
    "core-service",
    "frontend-service",
    "email-service",
    "map-service",
    "voting-service"
  ]
}

module "s3" {
  source = "./modules/s3"
}

module "secrets" {
  source = "./modules/secrets"
}

module "iam" {
  source    = "./modules/iam"
  user_name = "github-actions"

  # Attach only the policies this user actually needs
  policy_arns = [
    local.policy_arns.ecr_push,
  ]
}