# AWS Config

variable "aws_access_key" {
  default = "YOUR_ADMIN_ACCESS_KEY"
}

variable "aws_secret_key" {
  default = "YOUR_ADMIN_SECRET_KEY"
}

variable "aws_region" {
  default = "eu-west-1"
}

## VPC

variable "vpc_cidr" {
  type = "string"
  description = "CIDR of public VPC"
  default = "172.17.0.0/16"
}
variable "subnet_cidr" {
  type = "string"
  description = "CIDR of public subnet VPC"
  default = "172.17.10.0/24"
}

 ## AMI

  variable "ami_name_filter" {
   description = "Filter to use to find the AMI by name"
   default = "demo-aws-"
}
 
variable "ami_owner" {
   type = "string"
   description = "Filter for the AMI owner"
   default = "self"
}

## KEY PAIR

variable "public_key" {
   type = "string"
   description = "the public key to propagate"
   default = "YOUR_PUBLIC_KEY"
}
