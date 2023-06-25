resource "aws_eks_node_group" "group" {
  cluster_name = aws_eks_cluster.cluster.name

  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_worker_node.arn

  instance_types = var.instance_types
  ami_type       = var.ami_type

  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  tags = merge(var.default_tags, { "os" = var.ami_type }, var.common_tags, var.additional_tags)

  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

# IAM
resource "aws_iam_role" "eks_worker_node" {
  name               = "${var.cluster_name}-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_eks_worker_nodes.json
  tags               = merge(var.default_tags, var.common_tags, var.additional_tags)
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


resource "aws_iam_role_policy_attachment" "ExternalDNS" {
  policy_arn = aws_iam_policy.AllowExternalDNSUpdates.arn
  role       = aws_iam_role.eks_worker_node.name
}

resource "aws_iam_policy" "AllowExternalDNSUpdates" {
  name = "${var.cluster_name}-AllowExternalDNSUpdates"

  policy = jsonencode({
    Statement = [{
      Action = [
        "route53:ChangeResourceRecordSets"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}
