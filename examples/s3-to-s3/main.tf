#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# S3 location 3xample
module "s3_location" {
  source = "../../modules/datasync-locations"

  # Example S3 location
  {
    name          = "anycompany-bu1-appl1-logs"
    s3_bucket_arn = "arn:aws:s3:::anycompany-bu1-appl1-bucket",
    subdirectory  = "/logs/"
    create_role   = true
    tags          = { project = "datasync-module" }
  },
  {
    name          = "anycompany-bu1-backups"
    s3_bucket_arn = "arn:aws:s3:::anycompany-bu1-backups"
    create_role   = true
    tags          = { project = "datasync-module" }
  }

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
