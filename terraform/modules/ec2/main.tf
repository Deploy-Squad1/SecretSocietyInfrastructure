resource "aws_instance" "jenkins_server" {
    ami                    = var.ami_id
    instance_type          = var.instance_type
    subnet_id              = var.subnet_id
    vpc_security_group_ids = [var.security_group_id] 
    iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

    tags = {
        Name        = "jenkins-server-${var.env}"
        Environment = var.env
    }
}