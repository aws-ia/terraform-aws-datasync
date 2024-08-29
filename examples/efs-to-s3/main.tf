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
      name = "datasync-s3"
      # In this example a new S3 bucket is created in s3.tf
      s3_bucket_arn            = module.source-bucket.s3_bucket_arn
      subdirectory             = "/"
      create_role              = true
      s3_source_bucket_kms_arn = aws_kms_key.source-kms.arn

      tags = { project = "datasync-module" }
    }
  ]
}

# EFS location example
module "efs_location" {
  source = "../../modules/datasync-locations"
  efs_locations = [
    {
      name = "datasync-efs"
      # In this example a new EFS file system is created in efs.tf
      efs_file_system_arn            = aws_efs_file_system.efs.arn
      ec2_config_subnet_arn          = module.vpc.private_subnet_arns[0]
      ec2_config_security_group_arns = [aws_security_group.MyEfsSecurityGroup.arn]
      tags                           = { project = "datasync-module" }
    }
  ]

  # The mount target should exist before we create the EFS location
  depends_on = [aws_efs_mount_target.efs_subnet_mount_target]

}

# Task example
module "backup_tasks" {
  source = "../../modules/datasync-task"
  datasync_tasks = [
    {
      name                     = "efs_to_s3"
      source_location_arn      = module.s3_location.s3_locations["datasync-s3"].arn
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
