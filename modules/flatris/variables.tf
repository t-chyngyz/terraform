variable "ec2-type" {
  type    = string
  default = "t2.micro"
}

variable "ssh-key-name" {
  type  = string
}

variable "security-group-id" {
  type = list
}
