module "argocd" {
  # source = "git::https://github.com/brevanhowardinfra/tf-aws-bh-eks-core-infra.git//terraform/modules/argocd?ref=tf-bh-argocd-0.3.0"
  source = "../../../terraform/modules/argocd"

  account_name = local.account_name
  cluster_name = local.cluster_name
  namespace    = "argocd"

  businessunit = "mo"

  argocd_chart_version      = "5.32.1"
  argocd_apps_chart_version = "1.0.0"

  applications_values = file("${path.module}/data/argocd-apps/applications.yaml")
  repositories_values = file("${path.module}/data/argocd/configs/cm/repositories.yaml")

  depends_on = [module.eks_cluster]
}
