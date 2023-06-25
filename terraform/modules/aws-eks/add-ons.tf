resource "aws_eks_addon" "vpc_cni_addon" {
  cluster_name      = var.cluster_name
  addon_name        = "vpc-cni"
  addon_version     = var.vpc_cni_addon_version
  resolve_conflicts = "OVERWRITE"
  tags              = merge(var.default_tags, var.common_tags, var.additional_tags)
  depends_on = [
    aws_eks_cluster.cluster
  ]
}
