output "s3_locations" {
  description = "DataSync S3 Location ARNs"
  value       = module.s3_location.s3_locations
}

output "object_storage_locations" {
  description = "DataSync Object Storage Location ARNs"
  value       = module.object_storage_location.object_storage_locations
  sensitive   = true
}

output "backup_tasks" {
  description = "DataSync Task ARN"
  value       = module.backup_tasks.datasync_tasks
  sensitive   = true
}

output "datasync_src_role_arn" {
  description = "DataSync source S3 Location access IAM role ARN"
  value       = module.s3_location.datasync_role_arn["source-bucket"]
}
