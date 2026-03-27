output "instance_id" {
  description = "ID of the admin host instance"
  value       = aws_instance.admin_host.id
}

output "instance_arn" {
  description = "ARN of the admin host instance"
  value       = "arn:aws:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.admin_host.id}"
}
