resource "aws_eks_cluster" "cluster" {
  name                      = "${var.deploy_env}-${var.cluster_name}"
  role_arn                  = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = data.aws_subnets.private.ids
  }

  tags = merge(var.common_tags, var.additional_tags)

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.ElasticLoadBalancingFullAccess,
  ]
}

# IAM
resource "aws_iam_role" "eks_cluster" {
  name               = "${var.deploy_env}-${var.cluster_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_eks_cluster.json
  tags               = merge(var.common_tags, var.additional_tags)
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
