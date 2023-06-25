resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kube_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
    # endpoint_private_access = true
    # endpoint_public_access  = false
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.environment_kms_key.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = merge(var.default_tags, { "os" = var.ami_type }, var.common_tags, var.additional_tags)

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.ElasticLoadBalancingFullAccess,
    aws_cloudwatch_log_group.control_plane_logging
  ]
}

# IAM
resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_eks_cluster.json
  tags               = merge(var.default_tags, var.common_tags, var.additional_tags)
}

data "aws_iam_policy_document" "assume_role_policy_for_eks_cluster" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "ElasticLoadBalancingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.eks_cluster.name
}

# Control plane logging
resource "aws_cloudwatch_log_group" "control_plane_logging" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention
  kms_key_id        = aws_kms_key.environment_kms_key.arn
  tags              = merge(var.default_tags, var.common_tags, var.additional_tags)
}
