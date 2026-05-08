output "agent_arn" {
  description = "ARN of the activated DataSync agent"
  value       = module.datasync_agent.agent_arn
}

output "agent_public_ip" {
  description = "Public IP of the DataSync agent EC2 instance"
  value       = module.datasync_agent_ec2.public_ip
}

output "source_nfs_location_arn" {
  description = "DataSync source NFS location ARN (cross-account EFS)"
  value       = aws_datasync_location_nfs.source.arn
}

output "dest_efs_location_arn" {
  description = "DataSync destination EFS location ARN"
  value       = module.dest_efs_location.efs_locations["dest-efs"].arn
}

output "datasync_task" {
  description = "DataSync task"
  value       = module.datasync_task.datasync_tasks
}
