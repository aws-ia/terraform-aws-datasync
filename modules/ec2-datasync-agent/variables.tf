variable "availability_zone" {
  type        = string
  description = "Availability zone for the Datasync EC2 Instance"
}

variable "name" {
  default     = "aws-datasync-agent"
  type        = string
  description = "Name of the Datasync agent instance"
}

variable "source_subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in the EC2 Instance"
}

variable "source_vpc_id" {
  type        = string
  description = "The VPC ID in which the Datasync agent security group will be created in"
}

variable "security_group_id" {
  type        = string
  description = "Optionally provide an existing Security Group ID to associate with EC2 Datasync agent. Variable create_security_group should be set to false to use an existing Security Group"
  default     = null
}

variable "create_security_group" {
  type        = bool
  description = "Create a Security Group for the EC2 Datasync agent If create_security_group=false, provide a valid security_group_id"
  default     = false
}

variable "ingress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks to allow ingress into your Datasync agent for NFS and SMB client access. For multiple CIDR blocks, please separate with comma"
  default     = "10.0.0.0/16"
}

variable "egress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks for Datasync agent activation. Defaults to 0.0.0.0/0"
  default     = "0.0.0.0/0"
}

variable "ingress_cidr_block_activation" {
  type        = string
  description = "The CIDR block to allow ingress port 80 into your Datasync agent for activation. For multiple CIDR blocks, please separate with comma"
}

variable "instance_type" {
  default     = "m5.2xlarge"
  type        = string
  description = "The instance type to use for the Datasync agent. Choose m5.2xlarge for tasks to transfer up to 20 million files or m5.4xlarge for tasks to transfer more than 20 million files"
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Datasync agent"
  default     = null
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices in README.md for details"
  type        = map(any)
  default = {
    kms_key_id  = null
    disk_size   = 80
    volume_type = "gp3"
  }
}
