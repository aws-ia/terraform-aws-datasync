output "instance_id" {
  description = "The ID of the DataSync agent EC2 instance"
  value       = aws_instance.datasync_agent.id
}

output "public_ip" {
  description = "The Public IP address of the created Elastic IP"
  value       = aws_eip.agent_ip.public_ip
}

output "private_ip" {
  description = "The Private IP address of the DataSync agent on EC2"
  value       = aws_instance.datasync_agent.private_ip
}

output "ami_id" {
  description = "The AMI ID used for the DataSync agent EC2 instance"
  value       = aws_instance.datasync_agent.ami
}

output "security_group_id" {
  description = "The Security Group ID associated with the DataSync agent"
  value       = var.create_security_group ? aws_security_group.agent_sg[0].id : var.security_group_id
}
