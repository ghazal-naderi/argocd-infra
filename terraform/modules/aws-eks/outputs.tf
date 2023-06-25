output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "ca_cert" {
  value = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
}

output "iam_oidc_provider_endpoint" {
  value = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks_cluster.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_cluster.arn
}

output "aws_iam_openid_connect_provider_arn" {
  description = ""
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "aws_iam_openid_connect_provider_url" {
  description = ""
  value       = aws_iam_openid_connect_provider.eks.url
}
