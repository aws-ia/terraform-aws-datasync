variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "source_account_profile" {
  description = "AWS profile for the source account (contains source EFS, EC2 agent, and DataSync resources)"
  type        = string
  default     = "source-account"
}

variable "dest_account_profile" {
  description = "AWS profile for the destination account (contains destination EFS)"
  type        = string
  default     = "destination-account"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for the source account"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dest_vpc_cidr_block" {
  description = "VPC CIDR block for the destination account (must not overlap with source)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "ssh_key_name" {
  description = "Name of EC2 key pair for SSH access to the agent (optional)"
  type        = string
  default     = null
}
