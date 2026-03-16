provider "aws" {
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::485141927994:role/TerraformDeployRole"
  }
}
