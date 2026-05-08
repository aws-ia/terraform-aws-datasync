variable "agent_name" {
  type        = string
  description = "Name of the DataSync agent"
}

variable "agent_ip_address" {
  type        = string
  description = "IP address of the DataSync agent for activation. Terraform will make an HTTP GET request to port 80 on this IP."
}

variable "vpc_endpoint_id" {
  type        = string
  description = "(Optional) The ID of the VPC endpoint that the agent has access to"
  default     = null
}

variable "private_link_endpoint" {
  type        = string
  description = "(Optional) The IP address of the VPC endpoint the agent should connect to when retrieving an activation key"
  default     = null
}

variable "security_group_arns" {
  type        = list(string)
  description = "(Optional) The ARNs of the security groups used to protect your data transfer task subnets"
  default     = []
}

variable "subnet_arns" {
  type        = list(string)
  description = "(Optional) The ARNs of the subnets in which DataSync will create elastic network interfaces"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Key-value pairs of resource tags to assign to the DataSync agent"
  default     = {}
}

variable "agent_depends_on" {
  type        = any
  description = "(Optional) Resource dependencies to ensure agent is ready before activation"
  default     = null
}

variable "agent_boot_wait" {
  type        = string
  description = "Time to wait for the DataSync agent to boot before attempting activation (e.g., '3m', '5m')"
  default     = "3m"
}

variable "activation_region" {
  type        = string
  description = "AWS region for agent activation"
}
