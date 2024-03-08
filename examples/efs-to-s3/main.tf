#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# S3 location 3xample
module "s3_location" {
  source = "../../modules/datasync-locations"
  s3_locations = [
    {
      name          = "anycompany-bu1-appl1-logs"
      s3_bucket_arn = "arn:aws:s3:::anycompany-bu1-appl1-bucket",
      subdirectory  = "/logs/"
      create_role   = true
      tags          = { project = "datasync-module" }
    }
  ]
}

# EFS location example
module "efs_location" {
  source = "../../modules/datasync-locations"
  efs_locations = [
    {
      name                           = "datasync-efs"
      efs_file_system_arn            = aws_efs_file_system.efs.arn
      ec2_config_subnet_arn          = module.vpc.private_subnet_arns[0]
      ec2_config_security_group_arns = [aws_security_group.MyEfsSecurityGroup.arn]
      tags                           = { project = "datasync-module" }
    }
  ]
}

# Task example
module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "efs_to_s3"
      source_location_arn      = module.s3_location.s3_locations["scp-analyzer-project"].arn
      destination_location_arn = module.efs_location.efs_locations["datasync-efs"].arn
      options = {
        posix_permissions = "NONE"
        uid               = "NONE"
        gid               = "NONE"
      }
      schedule_expression = "cron(0 6 ? * MON-FRI *)" # Run at 6:00 am (UTC) every Monday through Friday:
    }
  ]
}
