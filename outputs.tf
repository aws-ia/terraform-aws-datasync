output "s3_locations" {
  value = aws_datasync_location_s3.s3_location
}

output "efs_locations" {
  value = aws_datasync_location_efs.efs_location
}

output "datasync_role_arn" {
  value = { for k, role in aws_iam_role.datasync_role_s3 : k => role.arn }
}

