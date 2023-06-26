resource "kubectl_manifest" "cluster_autoscaler_sa" {
  yaml_body = <<-EOF
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        annotations:
          meta.helm.sh/release-name: cluster_autoscaler
          meta.helm.sh/release-namespace: cluster_autoscaler
          eks.amazonaws.com/role-arn: arn:aws:iam::${local.account_id}:role/${var.cluster_name}-cluster_autoscaler-role
        name: cluster-autoscaler
        namespace: kube-system
      EOF
}

resource "kubectl_manifest" "cluster_autoscaler_cluster_role" {
  yaml_body = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        name: cluster-autoscaler
        labels:
          k8s-addon: cluster-autoscaler.addons.k8s.io
          k8s-app: cluster-autoscaler
      rules:
        - apiGroups: [""]
          resources: ["events", "endpoints"]
          verbs: ["create", "patch"]
        - apiGroups: [""]
          resources: ["pods/eviction"]
          verbs: ["create"]
        - apiGroups: [""]
          resources: ["pods/status"]
          verbs: ["update"]
        - apiGroups: [""]
          resources: ["endpoints"]
          resourceNames: ["cluster-autoscaler"]
          verbs: ["get", "update"]
        - apiGroups: [""]
          resources: ["nodes"]
          verbs: ["watch", "list", "get", "update"]
        - apiGroups: [""]
          resources:
            - "pods"
            - "services"
            - "replicationcontrollers"
            - "persistentvolumeclaims"
            - "persistentvolumes"
          verbs: ["watch", "list", "get"]
        - apiGroups: ["extensions"]
          resources: ["replicasets", "daemonsets"]
          verbs: ["watch", "list", "get"]
        - apiGroups: ["policy"]
          resources: ["poddisruptionbudgets"]
          verbs: ["watch", "list"]
        - apiGroups: ["apps"]
          resources: ["statefulsets", "replicasets", "daemonsets"]
          verbs: ["watch", "list", "get"]
        - apiGroups: ["storage.k8s.io"]
          resources: ["storageclasses", "csinodes"]
          verbs: ["watch", "list", "get"]
        - apiGroups: ["batch", "extensions"]
          resources: ["jobs"]
          verbs: ["get", "list", "watch", "patch"]
        - apiGroups: ["coordination.k8s.io"]
          resources: ["leases"]
          verbs: ["create"]
        - apiGroups: ["coordination.k8s.io"]
          resourceNames: ["cluster-autoscaler"]
          resources: ["leases"]
          verbs: ["get", "update"]
      EOF
}

resource "kubectl_manifest" "cluster_autoscaler_role" {
  yaml_body = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: Role
      metadata:
        name: cluster-autoscaler
        namespace: kube-system
        labels:
          k8s-addon: cluster-autoscaler.addons.k8s.io
          k8s-app: cluster-autoscaler
      rules:
        - apiGroups: [""]
          resources: ["configmaps"]
          verbs: ["create","list","watch"]
        - apiGroups: [""]
          resources: ["configmaps"]
          resourceNames: ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
          verbs: ["delete", "get", "update", "watch"]
      EOF
}

resource "kubectl_manifest" "cluster_autoscaler_cluster_role_binding" {
  yaml_body = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: cluster-autoscaler
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-autoscaler
    subjects:
      - kind: ServiceAccount
        name: cluster-autoscaler
        namespace: kube-system
      EOF
}

resource "kubectl_manifest" "cluster_autoscaler_role_binding" {
  yaml_body = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: cluster-autoscaler
      namespace: kube-system
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: cluster-autoscaler
    subjects:
      - kind: ServiceAccount
        name: cluster-autoscaler
        namespace: kube-system
      EOF
}

resource "kubectl_manifest" "cluster_autoscaler_deployment" {
  yaml_body = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cluster-autoscaler
      namespace: kube-system
      labels:
        app: cluster-autoscaler
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: cluster-autoscaler
      template:
        metadata:
          labels:
            app: cluster-autoscaler
          annotations:
            cluster-autoscaler.kubernetes.io/safe-to-evict: 'false'
        spec:
          serviceAccountName: cluster-autoscaler
          containers:
            - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.20.0
              name: cluster-autoscaler
              resources:
                limits:
                  cpu: 100m
                  memory: 500Mi
                requests:
                  cpu: 100m
                  memory: 500Mi
              command:
                - ./cluster-autoscaler
                - --v=4
                - --stderrthreshold=info
                - --cloud-provider=aws
                - --skip-nodes-with-local-storage=false
                - --expander=least-waste
                - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}
                - --balance-similar-node-groups
                - --skip-nodes-with-system-pods=false
              volumeMounts:
                - name: ssl-certs
                  mountPath: /etc/ssl/certs/ca-certificates.crt #/etc/ssl/certs/ca-bundle.crt for Amazon Linux Worker Nodes
                  readOnly: true
              imagePullPolicy: "Always"
          volumes:
            - name: ssl-certs
              hostPath:
                path: "/etc/ssl/certs/ca-bundle.crt"
      EOF
}
