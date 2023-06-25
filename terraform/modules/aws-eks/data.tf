data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  depends_on = [
    aws_eks_cluster.cluster
  ]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_roles" "admin" {
  name_regex  = "AWSReservedSSO_AD-admin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.name}"
}

data "aws_iam_roles" "dev" {
  name_regex  = "AWSReservedSSO_AD-developer_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.name}"
}

data "aws_iam_roles" "user" {
  name_regex  = "AWSReservedSSO_AWSPowerUserAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.name}"
}

data "aws_iam_roles" "autoscaling" {
  name_regex  = "AWSServiceRoleForAutoScaling.*"
  path_prefix = "/aws-service-role/autoscaling.amazonaws.com"
}
