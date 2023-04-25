data "aws_eks_cluster" "this" {
  name = "${local.deploy_env}-${local.cluster_name}"
  depends_on = [
    module.eks_cluster
  ]
}
