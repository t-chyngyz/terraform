terraform {
  backend "s3" {
    # Имя корзины, которое определили в самом начале
    bucket = "terraform-state-bucket-chyngyz"
    # Путь к файлу состояния Terraform
    key    = "global/s3/terraform-flatris.tfstate"
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

resource "aws_security_group" "allow_to_flatris" {
  name        = "allow_to_flatris"
  description = "Allow connection inbound traffic and to flatris"
  vpc_id      = "vpc-0dd45493ea1866269"

  tags = {
    Name = "allow_for_flatris"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_to_flatris.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_nodejs_ipv4" {
  security_group_id = aws_security_group.allow_to_flatris.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_to_flatris.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "flatris-ubuntu" {
  count                       = 1
  associate_public_ip_address = true
  ami                         = "ami-0e0cbc26960fa5f7b"
  instance_type               = var.ec2-type
  subnet_id                   = "subnet-0c621a57263c94961"
  key_name                    = aws_key_pair.ssh_key.key_name
  user_data = "${file("flatris_config.sh")}"
  security_groups = [ aws_security_group.allow_to_flatris.id ]
  tags = {
    Name = "flatris"
    role = "flatris"
  }
}

output "flatris-ubuntu-ip" {
  value = aws_instance.flatris-ubuntu[*].public_ip
}
