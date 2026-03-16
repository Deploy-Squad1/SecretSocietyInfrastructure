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
}

module "secrets" {
  source = "../../modules/secrets"
}
