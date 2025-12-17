variable "aws_region" {
  default = "us-east-1"
}

variable "db_name" {
  default = "mydb"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "client_ip_cidr" {
  description = "Optional CIDR (e.g., 203.0.113.5/32) allowed to access MySQL. If unset, Terraform detects your IP."
  type        = string
  default     = null
}