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
  # Example S3 location
  s3_locations = [
    {
      # In this example a new S3 bucket is created in s3.tf
      name                     = "source-bucket"
      s3_bucket_arn            = module.source_bucket.s3_bucket_arn
      subdirectory             = "/"
      create_role              = true
      s3_source_bucket_kms_arn = aws_kms_key.source-kms.arn
      s3_dest_bucket_kms_arn   = aws_kms_key.dest-kms.arn
      tags                     = { project = "datasync-module" }
    },
    {
      name                     = "dest-bucket"
      s3_bucket_arn            = module.dest_bucket.s3_bucket_arn
      subdirectory             = "/"
      create_role              = true
      s3_source_bucket_kms_arn = aws_kms_key.source-kms.arn
      s3_dest_bucket_kms_arn   = aws_kms_key.dest-kms.arn
      tags                     = { project = "datasync-module" }
    }
  ]
}

# Task example
module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "s3-to-s3-backup"
      source_location_arn      = module.s3_location.s3_locations["source-bucket"].arn
      destination_location_arn = module.s3_location.s3_locations["dest-bucket"].arn
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
        verify_mode       = "ONLY_FILES_TRANSFERRED"
      }
      schedule_expression = "rate(1 days)" # Run daily
      includes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "/logs/"
      }
      excludes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "*/temp"
      }
    }
  ]
}
