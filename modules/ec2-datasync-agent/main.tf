##########################
## Create EC2 Instance ##
##########################

locals {
  vpc_security_group_ids = var.create_security_group ? [aws_security_group.agent_sg[0].id] : [var.security_group_id]
}

# Lookup the latest DataSync agent AMI from SSM Parameter Store
data "aws_ssm_parameter" "datasync_ami" {
  count = var.ami_id == null ? 1 : 0
  name  = var.ssm_parameter_name
}

# Create the EC2 instance for DataSync agent
resource "aws_instance" "datasync_agent" {
  #checkov:skip=CKV_AWS_126:Detailed monitoring is optional for DataSync agents
  #checkov:skip=CKV2_AWS_41:IAM role attachment is optional - users can attach roles via instance profile variable if needed
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.datasync_ami[0].value
  vpc_security_group_ids = local.vpc_security_group_ids
  subnet_id              = var.subnet_id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  ebs_optimized          = true
  availability_zone      = var.availability_zone

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = try(tonumber(var.root_block_device["disk_size"]), 80)
    volume_type = try(var.root_block_device["volume_type"], "gp3")
    kms_key_id  = try(var.root_block_device["kms_key_id"], null)
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    precondition {
      condition     = var.create_security_group || try((length(var.security_group_id) > 3 && substr(var.security_group_id, 0, 3) == "sg-"), false)
      error_message = "Please specify create_security_group = true or provide a valid Security Group ID for var.security_group_id"
    }

    ignore_changes = [ami]
  }
}

# Create an Elastic IP for stable addressing
resource "aws_eip" "agent_ip" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-eip"
  }
}

# Associate the Elastic IP with the instance
resource "aws_eip_association" "agent_eip_assoc" {
  instance_id   = aws_instance.datasync_agent.id
  allocation_id = aws_eip.agent_ip.id
}
