output "my_s3_locations" {
  value = module.s3_location.s3_locations
}

output "my_efs_locations" {
  value = module.s3_location.s3_locations
}

output "backup_tasks" {
  value = module.backup_tasks.datasync_tasks
}
