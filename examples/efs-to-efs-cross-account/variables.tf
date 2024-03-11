variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_availability_zone" {
  description = "Availability Zone for the Subnet"
  default     = "us-east-1f"
}

variable "owner_profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "accepter_profile" {
  description = "AWS Profile"
  default     = "dest"
}

variable "source_vpc_id" {
  description = "Owner VPC Id"
  type        = string
}

variable "dest_vpc_id" {
  description = "Accepter VPC Id"
  type        = string
}

#variable "dest_vpc_cidr_block" {
#   description = "Destination VPC CIDR" 
#}

#variable "subnet-count" {
#    description = "# of Subnets to be created in the VPC"
#}

variable "ingress_cidr_blocks" {
  type        = string
  description = "The CIDR blocks to allow ingress into your File Gateway instance for NFS and SMB client access. For multiple CIDR blocks, please separate with comma"
  default     = "10.0.0.0/16"
}

variable "ingress_cidr_block_activation" {
  type        = string
  description = "The CIDR block to allow ingress port 80 into your File Gateway instance for activation. For multiple CIDR blocks, please separate with comma"
}

variable "source_subnet_id" {
  description = " Source subnet ID for the Datasync agent "
  type        = string
}

variable "dest_subnet_id" {
  description = " Dest subnet ID for the Datasync agent "
  type        = string
  default     = null
}

variable "ssh_key_name" {
  type        = string
  description = "(Optional) The name of an existing EC2 Key pair for SSH access to the EC2 Storage Gateway"
  default     = null
}

variable "ssh_public_key_path" {
  type        = string
  description = "(Optional) Absolute file path to the the public key for the EC2 Key pair. If ommitted, the EC2 key pair resource will not be created"
  default     = ""
}

variable "vpc_endpoint_subnet_ids" {
  type        = list(string)
  description = "Provide existing subnet IDs to associate with the VPC Endpoint. Must provide a valid values if create_vpc_endpoint=true."
  default     = null
}