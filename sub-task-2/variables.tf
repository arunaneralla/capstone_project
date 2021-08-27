variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.20.0.0/16"
}

variable "public_subnets_cidr" {
  description = "CIDR for the public subnet"
  type = list
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "CIDR for the private subnet"
  type = list
  default = ["10.20.3.0/24", "10.20.4.0/24"]
}

variable "azs" {
  description = "availability zones"
  type = list
  default = ["us-east-1a", "us-east-1b"]
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "public_key"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default = "aruna004"
}

