variable "s3_locations" {
  type = list(object({
    name                             = string
    agent_arns                       = optional(list(string))
    s3_bucket_arn                    = string
    s3_bucket_id                     = string
    s3_config_bucket_access_role_arn = optional(string)
    s3_storage_class                 = optional(string)
    subdirectory                     = optional(string)
    tags                             = optional(map(string))
    create_role                      = optional(bool)
    s3_bucket_policy                 = optional(bool)
  }))
  default     = []
  description = "A list of S3 locations and associated configuration"
}

variable "src-s3-location" {
  description = "Destination S3 Bucket"
  type        = string
}

# variable "dst-s3-location" {
#   description = "Destination S3 Bucket"
#   type        = string
# }

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "owner_profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "cross-account_profile" {
  description = "AWS Profile"
  default     = "dest"
}

