output "route53_name_servers" {
  description = "Name servers too configure at domain registrar"
  value       = aws_route53_zone.main.name_servers
}
