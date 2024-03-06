variable "datasync_name" {
  type        = string
  description = "Datasync Name"
}

variable "agent_ip_address" {
  type        = string
  description = "IP Address of Datasync"
}

# VPC Endpoint related variables

variable "datasync_vpc_endpoint" {
  type        = string
  description = "Existing VPC endpoint address to be used when activating your gateway. This variable value will be ignored if setting create_vpc_endpoint=true."
  default     = null
}

variable "create_vpc_endpoint" {
  type        = bool
  description = "Create an Interface VPC endpoint for Datasync"
  default     = false
}

variable "source_vpc_id" {
  type        = string
  description = "VPC id for creating a VPC endpoint. Must provide a valid value if create_vpc_endpoint=true."
  default     = null
}

variable "dest_vpc_id" {
  type        = string
  description = "VPC id for creating a VPC endpoint. Must provide a valid value if create_vpc_endpoint=true."
  default     = null
}

variable "vpc_endpoint_subnet_ids" {
  type        = list(string)
  description = "Provide existing subnet IDs to associate with the VPC Endpoint. Must provide a valid values if create_vpc_endpoint=true."
  default     = null
}

variable "create_vpc_endpoint_security_group" {
  type        = bool
  description = "Create a Security Group for the VPC Endpoint for Datasync Agent."
  default     = false
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "Optionally provide an existing Security Group ID to associate with the VPC Endpoint. Must be set if create_vpc_endpoint_security_group=false"
  default     = null
}

variable "datasync_private_ip_address" {
  type        = string
  description = "Inbound IP address of Datasync agent VM appliance for Security Group associated with VPC Endpoint. Must be set if create_vpc_endpoint=true"
  default     = null
}

variable "vpc_endpoint_private_dns_enabled" {
  type        = bool
  description = "Enable private DNS for VPC Endpoint"
  default     = false
}