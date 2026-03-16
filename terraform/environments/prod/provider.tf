provider "aws" {
  region = "eu-north-1"

  assume_role {
    role_arn = "arn:aws:iam::963947738852:role/TerraformDeployRole"
  }
}
