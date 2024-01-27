resource "aws_security_group" "allow_to_flatris" {
  name        = var.security-groups-name
  description = "Allow connection inbound traffic and to app"
  vpc_id      = "vpc-0dd45493ea1866269"

  tags = {
    Name = "allow_for_${var.security-groups-name}"
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
  from_port         = var.app-port
  ip_protocol       = "tcp"
  to_port           = var.app-port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_to_flatris.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

output "allow_to_flatris_id" {
  value = aws_security_group.allow_to_flatris.id
}