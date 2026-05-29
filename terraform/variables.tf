variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "blogging-app"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "eks_version" {
  default = "1.29"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "node_count" {
  default = 2
}

variable "container_port" {
  default = 8080
}
