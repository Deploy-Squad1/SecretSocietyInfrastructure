output "access_key_id" {
  description = "AWS Access Key ID for the IAM user"
  value       = aws_iam_access_key.this.id
}

output "secret_access_key" {
  description = "AWS Secret Access Key for the IAM user"
  value       = aws_iam_access_key.this.secret
  sensitive   = true
}

output "eks_admin_role_arn" {
  description = "ARN of the EKS admin role"
  value       = aws_iam_role.eks_admin.arn
}
