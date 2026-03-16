terraform {
  backend "s3" {
    bucket       = "secret-society-tf-state-deploysquad"
    key          = "stage/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
