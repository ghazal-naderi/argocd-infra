variable "cluster_name" {
  description = "Name of the EKS Cluster. Must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores (^[0-9A-Za-z][A-Za-z0-9-_]+$)."
  type        = string
}

variable "account_name" {
  description = "Name of the AWS account."
  type        = string
}

variable "aws_iam_openid_connect_provider_url" {
  type = string
}

variable "aws_iam_openid_connect_provider_arn" {
  type = string
}
