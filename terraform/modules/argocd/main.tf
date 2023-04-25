resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.chart_version == "" ? null : var.chart_version
  namespace  = var.namespace
  create_namespace = true
  lint = true
  values = [var.values]
}
