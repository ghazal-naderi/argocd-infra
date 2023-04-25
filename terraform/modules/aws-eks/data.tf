data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = "${var.deploy_env}-${var.cluster_name}"
}
