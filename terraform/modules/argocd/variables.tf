variable "businessunit" {
  description = "Business unit this cluster belongs to"
  type        = string
  default     = "mo"
  validation {
    condition     = contains(["mo", "fo"], var.businessunit)
    error_message = "Valid values for 'businessunit' variable are (mo, fo)."
  }
}

variable "namespace" {
  description = "Namespace to deploy Argo CD into"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version to use"
  type        = string
  default     = ""
}

variable "argocd_apps_chart_version" {
  description = "Argo CD Apps Helm chart version to use"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS Cluster. Must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores (^[0-9A-Za-z][A-Za-z0-9-_]+$)."
  type        = string
}

variable "account_name" {
  description = "Name of the AWS account."
  type        = string
}

variable "repositories_values" {
  description = "A YAML formatted list of repository values for Argo CD to create a repository connection with"
  default     = ""
}

variable "applications_values" {
  description = "A YAML formatted list of application values for Argo CD to deploy"
  default     = ""
}

variable "projects_values" {
  default = ""
}
