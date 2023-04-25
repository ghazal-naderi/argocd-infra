module "argocd" {
  source                 = "./modules/argocd"
  namespace              = "argocd"
  cluster_name           = "${local.deploy_env}-${local.cluster_name}"
  cluster_endpoint       = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  values                 = ""
}
