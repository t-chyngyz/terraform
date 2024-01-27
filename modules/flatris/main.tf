resource "aws_instance" "flatris-ubuntu" {
  count                       = 1
  associate_public_ip_address = true
  ami                         = "ami-0e0cbc26960fa5f7b"
  instance_type               = var.ec2-type
  subnet_id                   = "subnet-0c621a57263c94961"
  key_name                    = var.ssh-key-name
  user_data = "${file("flatris_config.sh")}"
  security_groups = var.security-group-id

  tags = {
    Name = "flatris"
    role = "flatris"
  }
}

output "flatris-ubuntu-ip" {
  value = aws_instance.flatris-ubuntu[*].public_ip
}
