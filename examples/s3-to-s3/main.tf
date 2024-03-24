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
      name = "anycompany-bu1-appl1-logs"
      # In this example a new S3 bucket is created in s3.tf
      s3_bucket_arn = aws_s3_bucket.appl1-bucket.arn
      subdirectory  = "/"
      create_role   = true
      tags          = { project = "datasync-module" }
    },
    {
      name          = "anycompany-bu1-backups"
      s3_bucket_arn = aws_s3_bucket.anycompany-bu1-backups.arn
      subdirectory  = "/"
      create_role   = true
      tags          = { project = "datasync-module" }
	}
  ]
}

# Task example
module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "s3-logs-backup"
      source_location_arn      = module.s3_location.s3_locations["anycompany-bu1-appl1-logs"].arn
      destination_location_arn = module.s3_location.s3_locations["anycompany-bu1-backups"].arn
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
      }
      schedule_expression = "rate(1 hour)" # Run every hour
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
