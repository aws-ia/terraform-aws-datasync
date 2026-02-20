#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# random pet prefix to name resources
resource "random_pet" "prefix" {
  length = 2
}

# S3 location Example
module "s3_location" {
  source = "../../modules/datasync-locations"
  s3_locations = [
    {
      name          = "source-bucket"
      s3_bucket_arn = module.source_bucket.s3_bucket_arn
      subdirectory  = "/"
      create_role   = true
      tags          = { project = "datasync-module" }
    }
  ]
}

# Object Storage location Example
module "object_storage_location" {
  source = "../../modules/datasync-locations"
  object_storage_locations = [
    {
      name            = "dest-object-storage"
      server_hostname = var.object_storage_hostname
      bucket_name     = var.object_storage_bucket_name
      access_key      = var.object_storage_access_key
      secret_key      = var.object_storage_secret_key
      server_protocol = var.object_storage_server_protocol
      server_port     = var.object_storage_server_port
      subdirectory    = "/"
      tags            = { project = "datasync-module" }
    }
  ]
}

# Task example
module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "s3-to-object-storage-backup"
      source_location_arn      = module.s3_location.s3_locations["source-bucket"].arn
      destination_location_arn = module.object_storage_location.object_storage_locations["dest-object-storage"].arn
      task_mode                = "ENHANCED"
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
        verify_mode       = "ONLY_FILES_TRANSFERRED"
      }
      schedule_expression = "rate(1 days)"
    }
  ]
}
