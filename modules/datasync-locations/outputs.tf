output "s3_locations" {
  value       = aws_datasync_location_s3.s3_location
  description = "DataSync S3 Location ARN"
}

output "efs_locations" {
  value       = aws_datasync_location_efs.efs_location
  description = "DataSync EFS Location ARN"
}

output "datasync_role_arn" {
  value       = { for k, role in aws_iam_role.datasync_role_s3 : k => role.arn }
  description = "DataSync Task ARN"
}

