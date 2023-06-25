
variable "cluster_name" {
  description = "Name of the EKS Cluster. Must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores (^[0-9A-Za-z][A-Za-z0-9-_]+$)."
  type        = string
}

variable "kube_version" {
  description = "Kubernetes version to provision"
  type        = string
  default     = "1.26"
}

variable "vpc_id" {
  description = "Desired VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired size of the worker node, the default value is 2"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the worker node, the default value is 5"
  type        = number
  default     = 5
}

variable "min_size" {
  description = "Minimum size of the worker node, the default value is 1"
  type        = number
  default     = 1
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU. Terraform will only perform drift detection if a configuration value is provided."
  type        = string
  default     = "AL2_x86_64"
}

variable "instance_types" {
  description = "List of instance types associated with the EKS Node Group. the default vaule is [\"m5.large\"]. Terraform will only perform drift detection if a configuration value is provided."
  type        = list(string)
  default     = ["m5.large"]
}

variable "cluster_log_retention" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 7
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "Map of required tags added to all resources in the aws-eks module."
  type        = map(string)
  default = {
    "ManagedBy" : "Terraform"
  }
}

variable "common_tags" {
  description = "Map of common tags to add to the module's resources. These tags are expected to be defined on a per account basis."
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Map of additional tags to add to the module's resources. These tags are expected to be defined on a per cluster basis."
  type        = map(string)
  default     = {}
}

variable "vpc_cni_addon_version" {
  description = "The AWS EKS VPC CNI add-on version"
  type        = string
  default     = ""
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}
