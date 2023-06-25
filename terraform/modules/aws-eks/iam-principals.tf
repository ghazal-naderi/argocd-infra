resource "kubernetes_config_map_v1_data" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(
      concat(
        [
          {
            rolearn  = "${aws_iam_role.eks_worker_node.arn}"
            username = "system:node:{{EC2PrivateDNSName}}"
            groups = [
              "system:bootstrappers",
              "system:nodes"
            ]
          }
        ],
        var.aws_auth_roles
      )
    )
    mapUsers = yamlencode(var.aws_auth_users)
  }
  force      = true
  depends_on = [aws_eks_cluster.cluster, aws_eks_node_group.group]
}
