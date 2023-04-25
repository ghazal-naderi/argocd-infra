variable "env" {
  description = "The deployment environment"
  type = string
  default = "dev"
}

variable "namespace" {
  description = "Namespace to deploy Argo CD into"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version to use"
  type        = string
  default = ""
}

variable "cluster_name" {
  description = "EKS cluster name"
  type    = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type    = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type    = string
}

variable "values" {
  description = "Path to JSON formatted values file"
}

variable "additional_tags" {
  description = "Tags to add to deployed module"
  type = map(string)
  default = {}
}
