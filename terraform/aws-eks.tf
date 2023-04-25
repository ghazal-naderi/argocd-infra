module "eks_cluster" {
  source       = "./modules/aws-eks"
  cluster_name = local.cluster_name
  deploy_env   = local.deploy_env
  vpc_id       = "vpc-0b1855f1457290eb5"
  common_tags = local.common_tags
}
