resource "aws_eks_node_group" "group" {
  node_group_name = "${var.deploy_env}-${var.cluster_name}-node-group"
  cluster_name    = aws_eks_cluster.cluster.name
  instance_types  = var.instance_types
  node_role_arn   = aws_iam_role.eks_worker_node.arn
  # ami_type        = var.ami_type
  # capacity_type   = var.capacity_type
  subnet_ids      = data.aws_subnets.private.ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  tags = merge(var.common_tags, var.additional_tags)

  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

# IAM
resource "aws_iam_role" "eks_worker_node" {
  name               = "${var.deploy_env}-${var.cluster_name}-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_eks_worker_nodes.json
  tags               = merge(var.common_tags, var.additional_tags)
}

data "aws_iam_policy_document" "assume_role_policy_for_eks_worker_nodes" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node.name
}

resource "aws_iam_role_policy_attachment" "attach_ssm_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_worker_node.name
}
