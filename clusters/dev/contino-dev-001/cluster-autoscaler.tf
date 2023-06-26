module "cluster-autoscaler" {
  #source = "git::https://github.com/brevanhowardinfra/tf-aws-bh-eks-core-infra.git//terraform/modules/cluster-autoscaler?ref=tf-bh-argocd-0.2.0"
  source = "../../../terraform/modules/autoscaler"

  account_name                        = local.account_name
  cluster_name                        = local.cluster_name
  aws_iam_openid_connect_provider_url = module.eks_cluster.aws_iam_openid_connect_provider_url
  aws_iam_openid_connect_provider_arn = module.eks_cluster.aws_iam_openid_connect_provider_arn

  depends_on = [module.eks_cluster]
}
