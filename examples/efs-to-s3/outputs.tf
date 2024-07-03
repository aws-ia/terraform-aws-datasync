output "my_s3_locations" {
  description = "DataSync S3 Location ARN"
  value       = module.s3_location.s3_locations
}

output "my_efs_locations" {
  description = "DataSync EFS Location ARN"
  value       = module.s3_location.s3_locations
}

output "backup_tasks" {
  description = "Datasync Task ARN"
  value       = module.backup_tasks.datasync_tasks
}
