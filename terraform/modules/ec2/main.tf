resource "aws_instance" "this" {
    ami          = var.ami_id
    instance_type = var.instance_type
    subnet_id     = var.subnet_id
    security_groups = [aws_security_group.this.id]
    iam_instance_profile = aws_iam_instance_profile.this.name

    tags = {
        Name = "jenkins-server-${var.env}"
        Environment = var.env
    }
}