variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "Name of EC2 key pair for SSH access (optional)"
  type        = string
  default     = null
}
