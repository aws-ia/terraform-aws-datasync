output "datasync_task_arn" {
  value       = module.backup_tasks.datasync_tasks
  description = "Datasync Task ARN"
}

output "my_s3_source_locations" {
  description = "DataSync S3 Source Location ARN"
  value       = module.s3_source_location.s3_locations.source-bucket
}

output "my_s3_dest_locations" {
  description = "DataSync S3 Destination Location ARN"
  value       = module.s3_dest_location.s3_locations.dest-bucket
}

output "datasync_dest_role_arn" {
  description = "DataSync Source S3 Access IAM role ARN"
  value       = aws_iam_role.datasync_dest_s3_access_role.arn
}

output "datasync_src_role_arn" {
  description = "DataSync Destination S3 Access IAM role ARN"
  value       = module.s3_source_location.datasync_role_arn["source-bucket"]
}