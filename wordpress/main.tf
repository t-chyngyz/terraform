terraform {
  backend "s3" {
    # Имя корзины, которое определили в самом начале
    bucket = "terraform-state-bucket-chyngyz"
    # Путь к файлу состояния Terraform
    key    = "global/s3/terraform-wordpress.tfstate"
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

resource "aws_security_group" "allow_to_wordpress" {
  name        = "allow_to_wordpress"
  description = "Allow connection inbound traffic and to flatris"
  vpc_id      = "vpc-0dd45493ea1866269"

  tags = {
    Name = "allow_for_wordpress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_to_wordpress.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_to_wordpress.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_to_wordpress.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "wordpress-ubuntu" {
  count                       = 1
  associate_public_ip_address = true
  ami                         = "ami-0e0cbc26960fa5f7b"
  instance_type               = var.ec2-type
  subnet_id                   = "subnet-0c621a57263c94961"
  key_name                    = aws_key_pair.ssh_key.key_name
  user_data                   = "${data.template_file.init.rendered}"
  security_groups = [ aws_security_group.allow_to_wordpress.id ]
  tags = {
    Name = "wordpress"
    role = "wordpress"
  }
}

data "aws_db_instance" "database" {
  db_instance_identifier = var.database-identifier
}

data "template_file" "init" {
  template = "${file("wordpress_config.sh.tpl")}"

  vars = {
    username = "${var.username}"
    password = "${var.password}"
    rds_endpoint       = trim("${data.aws_db_instance.database.endpoint}", ":3306")
  }
}

output "wordpress-ubuntu-ip" {
  value = aws_instance.wordpress-ubuntu[*].public_ip
}

