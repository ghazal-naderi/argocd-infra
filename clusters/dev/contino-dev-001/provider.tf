provider "aws" {
  region = "eu-west-2"
}

provider "kubernetes" {
  host                   = module.eks_cluster.endpoint
  cluster_ca_certificate = module.eks_cluster.ca_cert
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      local.cluster_name
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.endpoint
    cluster_ca_certificate = module.eks_cluster.ca_cert
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        local.cluster_name
      ]
    }
  }
}

provider "kubectl" {
  host                   = module.eks_cluster.endpoint
  cluster_ca_certificate = module.eks_cluster.ca_cert
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      local.cluster_name
    ]
  }
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}
