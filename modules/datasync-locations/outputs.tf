output "s3_locations" {
  description = "DataSync S3 Location ARN"
  value = aws_datasync_location_s3.s3_location
}

output "efs_locations" {
  description = "DataSync EFS Location ARN"
  value = aws_datasync_location_efs.efs_location
}

output "datasync_role_arn" {
  description = "DataSync Task ARN"
  value = { for k, role in aws_iam_role.datasync_role_s3 : k => role.arn }
}

