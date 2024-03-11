output "datasync_task_arn" {
  value       = module.backup_tasks.datasync_tasks
  description = "Datasync Task ARN"
  sensitive   = false
}

output "my_s3_source_locations" {
  value       = module.s3_location.s3_locations.source-bucket
  description = "DataSync S3 Location ARNs"
}

output "my_s3_dest_locations" {
  value       = module.s3_location.s3_locations.dest-bucket
  description = "DataSync S3 Location ARNs"
}