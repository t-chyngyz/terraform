variable "ec2-type" {
  type    = string
  default = "t2.micro"
}

variable "db-instance-type" {
  type = string
  default = "db.t3.micro"
}

variable "database-identifier" {
  type = string
  default = "rds-wordpress"
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}