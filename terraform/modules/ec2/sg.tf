resource "aws_security_group" "this" {
    name       = "jenkins-sg-${var.env}"
    description = "Security group for Jenkins server in ${var.env} environment"
    vpc_id      = var.vpc_id

    tags = {
        Name = "jenkins-sg-${var.env}"
        Environment = var.env
    }
}

resource "aws_vpc_security_group_egress_rule" "this"{
    security_group_id = aws_security_group.this.id
    description = "Allow HTTP outbound"
    from_port   = 80
    to_port     = 80
    ip_protocol    = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTPS outbound"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
