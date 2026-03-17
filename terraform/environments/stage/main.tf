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

  bucket_name     = "secret-society-media-ds-stage"
  allowed_origins = ["http://localhost:5173"]
}

module "secrets" {
  source = "../../modules/secrets"
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
      bucket_name = "secret-society-media-ds-stage"
      secret_arn  = module.secrets.map_service_secret_arn
    }
  }

}
