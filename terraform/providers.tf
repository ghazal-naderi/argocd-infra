terraform {
  backend "local" {}
}

provider "aws" {
  region = "eu-west-2"
}
