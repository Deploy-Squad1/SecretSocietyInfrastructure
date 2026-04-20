provider "aws" {
  region = "eu-north-1"

  allowed_account_ids = ["963947738852"]
}

provider "kubernetes" {
  host                   = "https://78F400693666EC3850FFF914038B7999.gr7.eu-north-1.eks.amazonaws.com:8443"
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
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
    host                   = "https://78F400693666EC3850FFF914038B7999.gr7.eu-north-1.eks.amazonaws.com:8443"
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args = [
        "--region", "eu-north-1",
        "eks", "get-token",
        "--cluster-name", module.eks.cluster_name
      ]
    }
  }
}
