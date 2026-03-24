output "access_key_id" {
  description = "AWS Access Key ID for the IAM user"
  value       = aws_iam_access_key.this.id
}

output "secret_access_key" {
  description = "AWS Secret Access Key for the IAM user"
  value       = aws_iam_access_key.this.secret
  sensitive   = true
}

output "eks_admin_role_arns" {
  description = "Map of dedicated EKS admin role ARNs"
  value = {
    for key, role in aws_iam_role.eks_admin : key => role.arn
  }
}
