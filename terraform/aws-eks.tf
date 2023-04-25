module "eks_cluster" {
  source       = "./modules/aws-eks"
  cluster_name = local.cluster_name
  deploy_env   = local.deploy_env
  vpc_id       = "vpc-08e264b11023831ac"
  common_tags = local.common_tags
}
