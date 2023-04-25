variable "deploy_env" {
  default = "dev"
}

variable "vpc_id" {
  description = "Desired VPC ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS Cluster. Must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores (^[0-9A-Za-z][A-Za-z0-9-_]+$)."
  type        = string
}

variable "desired_size" {
  description = "Desired size of the worker node, the default value is 2"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum size of the worker node, the default value is 2"
  type        = number
  default     = 5
}

variable "min_size" {
  description = "Minimum size of the worker node, the default value is 1"
  type        = number
  default     = 2
}

variable "instance_types" {
  description = "List of instance types associated with the EKS Node Group. the default vaule is [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided."
  type        = list(string)
  default     = ["m5.large"]
}

variable "common_tags" {
  description = "Map of common tags to add to module's resources"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Map of additional tags to add to module's resources"
  type        = map(string)
  default     = {}
}
