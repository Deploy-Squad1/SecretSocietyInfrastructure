terraform {
  backend "s3" {
    bucket       = "secret-society-tf-state-prod"
    key          = "prod/terraform.tfstate"
    region       = "eu-north-1"
    profile      = "prod"
    use_lockfile = true
  }
}
