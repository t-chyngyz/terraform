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