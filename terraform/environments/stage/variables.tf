variable "team_user_arns" {
  description = "IAM users allowed to assume team role"
  type        = list(string)
}

variable "domain_name" {
  description = "Root domain name managed in Route 53"
  type        = string
}

variable "app_domain" {
  description = "FQDN for the application"
  type        = string
}

variable "lb_dns_name" {
  description = "DNS name of the AWS Load Balancer created by Kubernetes"
  type        = string
}

variable "lb_zone_id" {
  description = "Hosted zone ID of the AWS Load Balancer (not Route53 zone)"
  type        = string
}
