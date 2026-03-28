provider "aws" {
  region = "eu-north-1"

  allowed_account_ids = ["983988120210"]
}

provider "kubernetes" {
  host     = "https://localhost:8443"
  insecure = true

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "--region", "eu-north-1",
      "eks", "get-token",
      "--cluster-name", module.eks.cluster_name
    ]
  }
}

provider "helm" {
  kubernetes = {
    host     = "https://localhost:8443"
    insecure = true

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "--region", "eu-north-1",
        "eks", "get-token",
        "--cluster-name", module.eks.cluster_name
      ]
    }
  }
}
