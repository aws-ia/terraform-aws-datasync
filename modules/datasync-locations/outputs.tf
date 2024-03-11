output "s3_locations" {
  value = aws_datasync_location_s3.s3_location
}

output "efs_locations" {
  value = aws_datasync_location_efs.efs_location
}