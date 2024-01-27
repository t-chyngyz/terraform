terraform {
  backend "s3" {
    # Имя корзины, которое определили в самом начале
    bucket = "terraform-state-bucket-chyngyz"
    # Путь к файлу состояния Terraform
    key = "global/s3/terraform-ec2.tfstate"
    region = "eu-central-1"
    
    # Имя таблицы в DynamoDB, которое определили в самом начале
    dynamodb_table = "terraform-state-locks"
    encrypt = true 
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

resource "aws_instance" "from-terraform-ubuntu" {
  count = 1
  ami = "ami-0e0cbc26960fa5f7b"
  instance_type = var.ec2-type
  subnet_id = "subnet-0b722ffeafb005890"
  tags = {
    Name = "from-terraform"
    role = "nginx"
  }
}

resource "aws_instance" "from-terraform-al" {
  count = 1
  ami = "ami-025a6a5beb74db87b"
  instance_type = var.ec2-type
  subnet_id = "subnet-0c621a57263c94961"
  tags = {
    Name = "from-terraform"
    role = "nginx"
  }
}
