output "agent_public_ip" {
  description = "Public IP of the DataSync agent"
  value       = module.datasync_agent_ec2.public_ip
}

output "agent_private_ip" {
  description = "Private IP of the DataSync agent"
  value       = module.datasync_agent_ec2.private_ip
}

output "agent_instance_id" {
  description = "EC2 instance ID of the DataSync agent"
  value       = module.datasync_agent_ec2.instance_id
}

output "agent_arn" {
  description = "ARN of the activated DataSync agent"
  value       = module.datasync_agent_activation.agent_arn
}

output "agent_id" {
  description = "ID of the activated DataSync agent"
  value       = module.datasync_agent_activation.agent_id
}
