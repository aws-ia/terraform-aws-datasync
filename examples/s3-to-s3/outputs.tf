output "my_s3_locations" {
  description = "DataSync S3 Location ARNs"
  value       = module.s3_location.s3_locations
}

output "backup_tasks" {
  description = "DataSync Task ARN"
  value       = module.backup_tasks.datasync_tasks
}

output "datasync_src_role_arn" {
  description = "DataSync source S3 Location access IAM role ARN"
  value       = module.s3_location.datasync_role_arn["source-bucket"]
}

output "datasync_dest_role_arn" {
  description = "DataSync destination S3 Location access IAM role ARN"
  value       = module.s3_location.datasync_role_arn["dest-bucket"]
}
