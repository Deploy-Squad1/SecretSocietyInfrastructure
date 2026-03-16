terraform {
  backend "s3" {
    bucket       = "secret-society-tf-state-deploysquad"
    key          = "prod/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
