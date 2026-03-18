output "agent_arn" {
  description = "Amazon Resource Name (ARN) of the DataSync agent"
  value       = aws_datasync_agent.agent.arn
}

output "agent_id" {
  description = "ID of the DataSync agent"
  value       = aws_datasync_agent.agent.id
}

output "agent_name" {
  description = "Name of the DataSync agent"
  value       = aws_datasync_agent.agent.name
}
