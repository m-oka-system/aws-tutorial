# Common
variable "region" {
  default = "ap-northeast-1"
}

variable "zones" {
  type = "list"

  default = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]
}

# EC2
variable "key_pair" {}

# VPC
variable "vpc_name" {}
variable "vpc_prefix" {}
variable "alb_name" {}

# RDS
variable "sql_login" {}
variable "sql_password" {}
variable "db_instance_name" {}
variable "database_name" {}

# S3
variable "bucket_name" {}

# Route53
variable "domain_name" {}

# IAM
variable "iam_groups" {
  type = "list"

  default = [
    "app-group",
    "infra-group",
  ]
}

variable "iam_app_users" {
  type = "list"
}

variable "iam_infra_users" {
  type = "list"
}

variable "keybase_user_name" {}
