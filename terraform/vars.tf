variable "vpc_id" {}
variable "subnet_id" {}
variable "security_group" {}
variable "key_name" {}
variable "ami_id" {}
variable "region" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "asg_min_size" {
  default = 2
}

variable "asg_max_size" {
  default = 4
}

variable "asg_desired_capacity" {
  default = 2
}
