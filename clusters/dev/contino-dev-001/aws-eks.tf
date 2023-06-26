variable "common_tags" {
  description = "Map of common tags to add to module's resources"
  type        = map(string)
  default     = {}
}

module "eks_cluster" {
  # source = "git::https://github.com/brevanhowardinfra/tf-aws-bh-eks-core-infra.git//terraform/modules/aws-eks?ref=tf-bh-aws-eks-0.2.0"
  source = "../../../terraform/modules/aws-eks"

  cluster_name = local.cluster_name
  kube_version = "1.27"

  vpc_id = "vpc-05e1a10dc679128bd"
  private_subnet_ids = [
    "subnet-09a21275cd1edc9c1",
    "subnet-072c1779470b87895",
    "subnet-0109f53eb70f9c49d"
  ]

  # aws_auth_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${one(data.aws_iam_roles.admin.names)}"
  #     username = "AD-admin"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${one(data.aws_iam_roles.dev.names)}"
  #     username = "AD-developer"
  #     groups   = ["system:masters"]
  #   }
  # ]
  # aws_auth_users = [
  #   {
  #     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/ci-user"
  #     username = "ci-user"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/external-secrets"
  #     username = "external-secrets"
  #     groups   = ["system:masters"]
  #   }
  # ]

  desired_size   = 2
  max_size       = 5
  min_size       = 1
  instance_types = ["m5.large"]

  vpc_cni_addon_version = "v1.12.6-eksbuild.2"

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  cluster_log_retention = 1

  common_tags     = var.common_tags
  additional_tags = {}
}
