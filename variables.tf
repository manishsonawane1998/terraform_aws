variable "cidr_block_vpc" {
  type = string
  default = "20.20.0.0/16"
}

variable "vpc_name" {
  type = string
  default = "testvpc"
}

variable "availability_zone_public" {
  type = string
  default = "us-east-1a"
}

variable "cidr_block_public" {
  type = string
  default = "20.20.1.0/24"
}

variable "availability_zone_private" {
  type = string
  default = "us-east-1b"
}

variable "cidr_block_private" {
  type = string
  default = "20.20.2.0/24"
}

variable "internet_gateway_name" {
  type = string
  default = "testgw"
}

variable "nat_gateway_name" {
  type = string
  default = "testnat"
}

variable "instance_security_group_name" {
  type = string
  default = "TestSG"
}

variable "public_instance_name" {
  type = string
  default = "Publicserver"
}

variable "public_instance_ami" {
  type = string
  default = "ami-0015b9ef68c77328d"
}

variable "public_instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
  default = "terraform_demo"
}

variable "private_instance_name" {
  type = string
  default = "Privateserver"
}

variable "private_instance_ami" {
  type = string
  default = "ami-0015b9ef68c77328d"
}

variable "private_instance_type" {
  type = string
  default = "t2.micro"
}

variable "load_balancer_name" {
  type = string
  default =  "my-test-lb"
}

variable "load_balancer_type" {
  type = string
  default =  "application"
}

variable "load_balancer_security_group" {
  type = string
  default =  "my-alb-sg"
}



