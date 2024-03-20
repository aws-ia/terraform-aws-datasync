output "datasync_task_arn" {
  value       = module.backup_tasks.datasync_tasks
  description = "Datasync Task ARN"
  sensitive   = false
}

output "my_s3_source_locations" {
  value       = module.s3_source_location.s3_locations.source-bucket
  description = "DataSync S3 Source Location ARNs"
}

output "my_s3_dest_locations" {
  value       = module.s3_dest_location.s3_locations.dest-bucket
  description = "DataSync S3 Destination Location ARNs"
}

output "datasync_src_role_arn" {
  value = aws_iam_role.datasync_source_s3_access_role.arn
}

# output "datasync_dest_role_arn" {
#   value = module.s3_dest_location.datasync_role_arn["dest-bucket"]
# }