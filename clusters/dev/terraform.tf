terraform {
  # cloud {
  #   organization = "brevanhoward"

  #   workspaces {
  #     name = "eks-core-infra-bh-it-dev"
  #   }
  # }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
