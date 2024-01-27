terraform {
  backend "s3" {
    # Имя корзины, которое определили в самом начале
    bucket = "terraform-state-bucket-chyngyz"
    # Путь к файлу состояния Terraform
    key    = "global/s3/terraform-flatris-from-module.tfstate"
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

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "security_groups-flatris" {
  source = "../modules/security-group"
}

module "flatris" {
  source = "../modules/flatris"
  ec2-type = "t2.micro"
  ssh-key-name = aws_key_pair.ssh_key.key_name
  security-group-id = [ module.security_groups-flatris.allow_to_flatris_id ]
}

module "flatris2" {
  source = "../modules/flatris"
  ec2-type = "t2.micro"
  ssh-key-name = aws_key_pair.ssh_key.key_name
  security-group-id = [ module.security_groups-flatris.allow_to_flatris_id ]
}

output "flatris-from-module-ip" {
  value = module.flatris.flatris-ubuntu-ip
}

output "flatris-from-module-ip2" {
  value = module.flatris2.flatris-ubuntu-ip
}
