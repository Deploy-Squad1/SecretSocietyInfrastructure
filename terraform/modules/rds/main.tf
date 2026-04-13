resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  identifier     = var.name
  engine         = "postgres"
  engine_version = "18.3"

  allow_major_version_upgrade = true
  apply_immediately           = true

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  db_name           = var.db_name
  username          = var.username
  password          = var.password
  port              = var.port

  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = var.security_group_ids

  publicly_accessible = false

  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period

  multi_az = var.multi_az

  tags = {
    Name = var.name
  }
}
