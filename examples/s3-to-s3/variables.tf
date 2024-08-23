variable "region" {
  type        = string
  description = "The AWS region for this deployment"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block for the creation of example VPC and subnets"
  default     = "10.0.0.0/16"
}

variable "efs_security_group_egress_cidr_block" {
  type        = string
  description = "IPv4 CIDR block for egress traffic for EFS and Datasync security group"
  default     = "0.0.0.0/0"
}

variable "subnet-count" {
  type        = number
  description = "Number of sunbets per type"
  default     = 1
}
