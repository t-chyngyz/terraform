terraform {
  backend "s3" {
    # Имя корзины, которое определили в самом начале
    bucket = "terraform-state-bucket-chyngyz"
    # Путь к файлу состояния Terraform
    key    = "global/s3/terraform-mysql.tfstate"
    region = "eu-central-1"

    # Имя таблицы в DynamoDB, которое определили в самом начале
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "allow_to_mysql" {
  name        = "allow_to_mysql"
  description = "Allow connection inbound traffic to RDS MySQL"
  vpc_id      = "vpc-0dd45493ea1866269"

  tags = {
    Name = "allow_for_mysql"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_ipv4" {
  security_group_id = aws_security_group.allow_to_mysql.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_to_mysql.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_db_subnet_group" "RDS_subnet_group" {
  name = "wordpress-db-subnet"
  subnet_ids = ["subnet-0b722ffeafb005890", "subnet-0fa53e244b27d6bd1"]
  tags = {
    Name = "wordpress-db-subnet"
  }
}

resource "aws_db_instance" "mysql-wordpress" {
  allocated_storage      = 20
  db_name                = "wordpress"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db-instance-type
  port                   = "3306"
  vpc_security_group_ids = ["${aws_security_group.allow_to_mysql.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.RDS_subnet_group.name}"
  identifier             = var.database-identifier
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  tags = {
    Name = "mysql-wordpress"
  }
}

output "RDS-endpoint" {
  value = aws_db_instance.mysql-wordpress.endpoint
}


