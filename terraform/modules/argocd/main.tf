locals {
  # This locals block is building the values files that are applied to the Argo CD and Argo CD Apps Helm charts.
  # It combines values defined at the cluster level and module level. If you need to add a new key to one of the
  # values file follow the pattern for one of the existing examples.

  ###########################################################################################################

  # Argo CD Helm chart values

  ###########################################################################################################

  # server:
  extra_args_values = indent(2, format("extraArgs:\n%s", file("${path.module}/data/argocd/server/extraArgs.yaml")))
  ingress_values    = indent(2, format("ingress:\n%s", templatefile("${path.module}/data/argocd/server/ingress.yaml", { cluster_name = "${var.cluster_name}", account_name = "${var.account_name}" })))
  server_values = indent(2, format("server:\n%s",
    join("\n",
      [
        local.extra_args_values,
        local.ingress_values
      ]
    )
  ))

  # configs:
  #   cm:
  config_management_plugins_values = indent(2, format("configManagementPlugins: |\n%s", file("${path.module}/data/argocd/configs/cm/configManagementPlugins.yaml")))

  module_repositories_values = file("${path.module}/data/argocd/configs/cm/repositories.yaml")
  combined_repositories_values = indent(2, format("repositories: |\n%s",
    join("\n",
      [
        local.module_repositories_values,
        var.repositories_values
      ]
    )
  ))

  cm_values = indent(2, format("cm:\n%s",
    join("\n",
      [
        local.config_management_plugins_values,
        local.combined_repositories_values
      ]
    )
  ))

  configs_values = indent(2, format("configs:\n%s",
    join("\n",
      [
        local.cm_values
      ]
    )
  ))

  # argocd_values
  argocd_values = join("\n",
    [
      local.server_values,
      local.configs_values
    ]
  )

  ###########################################################################################################

  # Argo CD Apps Helm chart values

  ###########################################################################################################

  module_applications_values = templatefile("${path.module}/data/argocd-apps/applications.yaml", { businessunit = "${var.businessunit}" })
  combined_applications_values = indent(2, format("applications:\n%s",
    join("\n",
      [
        local.module_applications_values,
        var.applications_values
      ]
    )
  ))

  module_projects_values = file("${path.module}/data/argocd-apps/projects.yaml")
  combined_projects_values = indent(2, format("projects:\n%s",
    join("",
      [
        local.module_projects_values,
        var.projects_values
      ]
    )
  ))

  argocd_apps_values = join("\n",
    [
      local.combined_applications_values,
      local.combined_projects_values
    ]
  )
}

resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.argocd_chart_version == "" ? null : var.argocd_chart_version
  namespace        = var.namespace
  create_namespace = true
  lint             = true
  values           = [local.argocd_values]
}

resource "helm_release" "argocd_apps" {
  name             = "argocd-apps"
  chart            = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.argocd_apps_chart_version == "" ? null : var.argocd_apps_chart_version
  namespace        = var.namespace
  create_namespace = true
  lint             = true
  values           = [local.argocd_apps_values]
  depends_on       = [helm_release.argocd]
}
