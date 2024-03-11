#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#######################################
#Providers for Source and Dest Accounts
#######################################

provider "aws" {
  # alias = "src"
  profile = var.owner_profile
  region  = var.region
}

provider "aws" {
  alias   = "dest"
  region  = var.region
  profile = var.cross-account_profile
}

# Create Datasync S3 locations

module "s3_location" {
  source = "../../modules/datasync-locations"
  # providers =  {
  #   aws.dst  = aws.dest
  #   aws.src  = aws
  # }
  s3_locations = var.s3_locations

}


# Create DataSync Task
module "backup_tasks" {
  source = "../../modules/datasync-task"


  datasync_tasks = [
    {
      name                     = "s3_to_s3_task"
      source_location_arn      = module.s3_location.s3_locations["source-bucket"].arn
      destination_location_arn = module.s3_location.s3_locations["dest-bucket"].arn
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
      }
      schedule_expression = "rate(1 hour)" # Run every hour
      includes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "/projects/important-folder"
      }
      excludes = {
        "filter_type" = "SIMPLE_PATTERN"
        "value"       = "*/work-in-progress"
      }
    }
  ]
}


