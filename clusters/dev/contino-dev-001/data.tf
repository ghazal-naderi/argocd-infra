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

data "aws_vpcs" "this" {
  tags = {
    Name = "*-vpc"
  }
}

data "aws_vpc" "this" {
  id = one(data.aws_vpcs.this.ids[*])
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  tags = {
    Name = "eks1-*"
  }
}
