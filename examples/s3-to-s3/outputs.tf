output "my_s3_locations" {
  value = module.s3_location.s3_locations
}

output "backup_tasks" {
  value = module.backup_tasks.datasync_tasks
}

output "datasync_src_role_arn" {
  value = module.s3_location.datasync_role_arn["source-bucket"]
}

output "datasync_dest_role_arn" {
  value = module.s3_location.datasync_role_arn["dest-bucket"]
}
