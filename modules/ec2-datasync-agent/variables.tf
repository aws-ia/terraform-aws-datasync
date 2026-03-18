variable "ami_id" {
  type        = string
  description = "(Optional) Specific AMI ID for the DataSync agent. If not provided, the latest AMI is fetched from SSM Parameter Store using ssm_parameter_name."
  default     = null
}

variable "ssm_parameter_name" {
  type        = string
  description = "SSM parameter path for the DataSync agent AMI."
  default     = "/aws/service/datasync/ami/v3"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which the DataSync agent security group will be created"
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch the EC2 instance"
}

variable "name" {
  type        = string
  description = "Name of the EC2 DataSync agent instance"
  default     = "datasync-agent"
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the DataSync agent."
  default     = "m6a.2xlarge"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the agent EC2 instance. If not specified, will be determined by the subnet."
  default     = null
}

variable "create_security_group" {
  type        = bool
  description = "Create a Security Group for the EC2 DataSync agent. If false, provide a valid security_group_id."
  default     = false
}

variable "security_group_id" {
  type        = string
  description = "Existing Security Group ID to associate with the EC2 DataSync agent. Required if create_security_group is false."
  default     = null
}

variable "ingress_cidr_blocks" {
  type        = string
  description = "CIDR blocks to allow ingress into the DataSync agent for management access (port 443). Comma-separated for multiple."
  default     = "10.0.0.0/16"
}

variable "ingress_cidr_block_activation" {
  type        = string
  description = "CIDR block to allow ingress port 80 for agent activation. Comma-separated for multiple."
  default     = "0.0.0.0/0"
}

variable "egress_cidr_blocks" {
  type        = string
  description = "CIDR blocks for agent egress traffic."
  default     = "0.0.0.0/0"
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) EC2 Key pair name for SSH access to the DataSync agent."
  default     = null
}

variable "root_block_device" {
  type        = map(any)
  description = "Root block device configuration for the instance."
  default = {
    disk_size   = 80
    kms_key_id  = null
    volume_type = "gp3"
  }
}
