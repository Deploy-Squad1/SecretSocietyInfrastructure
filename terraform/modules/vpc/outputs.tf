output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}
