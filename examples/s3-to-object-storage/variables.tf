variable "region" {
  type        = string
  description = "The AWS region for this deployment"
  default     = "us-east-1"
}

variable "object_storage_hostname" {
  type        = string
  description = "The hostname of the S3-compatible object storage server"
}

variable "object_storage_bucket_name" {
  type        = string
  description = "The bucket name on the object storage server"
}

variable "object_storage_access_key" {
  type        = string
  description = "The access key for authenticating with the object storage server"
  sensitive   = true
}

variable "object_storage_secret_key" {
  type        = string
  description = "The secret key for authenticating with the object storage server"
  sensitive   = true
}

variable "object_storage_server_protocol" {
  type        = string
  description = "The protocol used to communicate with the object storage server (HTTP or HTTPS)"
  default     = "HTTPS"
}

variable "object_storage_server_port" {
  type        = number
  description = "The port the object storage server accepts traffic on"
  default     = 443
}
