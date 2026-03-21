output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = [
    for key in sort(keys(aws_subnet.private)) : aws_subnet.private[key].id
  ]
}

output "cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    for key in sort(keys(aws_subnet.public)) : aws_subnet.public[key].id
  ]
}