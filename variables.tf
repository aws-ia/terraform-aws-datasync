# A list of S3 location configuration objects. See S3 Locations for supported attributes
variable "s3_locations" {
  type = list(object({
    name                             = string
    agent_arns                       = optional(list(string))
    s3_bucket_arn                    = string
    s3_config_bucket_access_role_arn = optional(string)
    s3_storage_class                 = optional(string)
    subdirectory                     = optional(string)
    region                           = optional(string)
    tags                             = optional(map(string))
    create_role                      = optional(bool)
  }))
  default     = []
  description = "A list of S3 locations and associated configuration"
}

# A list of EFS location configuration objects. See EFS Locations for supported attributes
variable "efs_locations" {
  type = list(object({
    name                           = string
    access_point_arn               = optional(string)
    ec2_config_security_group_arns = list(string)
    ec2_config_subnet_arn          = string
    efs_file_system_arn            = string
    file_system_access_role_arn    = optional(string)
    in_transit_encryption          = optional(string)
    subdirectory                   = optional(string)
    region                         = optional(string)
    tags                           = optional(map(string))
  }))
  default     = []
  description = "A list of EFS locations and associated configuration"
}

# A list of Object Storage location configuration objects. See Object Storage Locations for supported attributes
variable "object_storage_locations" {
  type = list(object({
    name               = string
    server_hostname    = string
    bucket_name        = string
    agent_arns         = optional(list(string))
    access_key         = optional(string)
    secret_key         = optional(string)
    server_port        = optional(number)
    server_protocol    = optional(string)
    server_certificate = optional(string)
    subdirectory       = optional(string)
    region             = optional(string)
    tags               = optional(map(string))
  }))
  default     = []
  description = "A list of Object Storage locations and associated configuration"
}

