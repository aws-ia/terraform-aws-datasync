output "datasync_agent_arn" {
  value       = module.datasync.datasync
  description = "Datasync Agent ARN"
  sensitive   = false
}


