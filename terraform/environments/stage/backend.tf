terraform {
  backend "s3" {
    bucket       = "secret-society-tf-state-stage"
    key          = "stage/terraform.tfstate"
    region       = "eu-north-1"
    profile      = "stage"
    use_lockfile = true
  }
}
