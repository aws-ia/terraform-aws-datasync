#####################################################################################
# EFS-to-EFS Cross-Account DataSync with EC2 Agent
#
# This example demonstrates:
# - Deploying a DataSync EC2 agent in the source account
# - Activating the agent using the datasync-agent module
# - VPC peering between source and destination accounts
# - Cross-account EFS configured as NFS source location (accessed via agent + peering)
# - Local EFS configured as native EFS destination location
# - DataSync task syncing from cross-account EFS to local EFS
#
# Architecture: DataSync runs in Account A (source account). The cross-account EFS
# (Account B) is configured as an NFS location accessed through the agent via VPC
# peering. The local EFS (Account A) is a native EFS location. Per AWS docs,
# cross-account EFS-to-EFS requires the remote EFS to be an NFS location with an agent.
#####################################################################################

locals {
  name = "datasync-efs-cross-account"
  # EFS DNS name for the cross-account EFS (used as NFS source)
  cross_account_efs_dns = "${aws_efs_file_system.destination.id}.efs.${var.region}.amazonaws.com"
}

data "aws_caller_identity" "source" {}

# Latest Basic mode DataSync agent AMI (required for NFS location / cross-account EFS tasks)
data "aws_ami" "datasync_basic" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["aws-datasync-2.0.*-x86_64-gp2"]
  }
}

#############################
# EC2 DataSync Agent
#############################

module "datasync_agent_ec2" {
  source = "../../modules/ec2-datasync-agent"

  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  name          = "${local.name}-agent"
  instance_type = "m6a.2xlarge"

  # Cross-account EFS-to-EFS requires a Basic mode agent (NFS locations only support Basic mode tasks)
  # Use the latest Basic mode AMI since only v3 (Enhanced) is in SSM Parameter Store
  ami_id = data.aws_ami.datasync_basic.id

  create_security_group         = true
  ingress_cidr_blocks           = var.vpc_cidr_block
  ingress_cidr_block_activation = "0.0.0.0/0"

  ssh_key_name = var.ssh_key_name
}

#############################
# Activate DataSync Agent
#############################

module "datasync_agent" {
  source = "../../modules/datasync-agent"

  agent_name        = "${local.name}-agent"
  agent_ip_address  = module.datasync_agent_ec2.public_ip
  activation_region = var.region

  tags = {
    Environment = "cross-account"
    Purpose     = "efs-to-efs-sync"
  }

  agent_depends_on = module.datasync_agent_ec2
}

#############################
# Source NFS Location
# (Cross-account EFS accessed via NFS through agent + VPC peering)
#############################

resource "aws_datasync_location_nfs" "source" {
  server_hostname = local.cross_account_efs_dns
  subdirectory    = "/"

  on_prem_config {
    agent_arns = [module.datasync_agent.agent_arn]
  }

  mount_options {
    version = "NFS4_1"
  }

  tags = { project = "datasync-efs-cross-account" }

  depends_on = [
    aws_efs_mount_target.destination,
    aws_efs_file_system_policy.destination,
    aws_route.source_to_dest,
    aws_route.dest_to_source
  ]
}

#############################
# Destination EFS Location (native)
# Same account as DataSync
#############################

module "dest_efs_location" {
  source = "../../modules/datasync-locations"

  efs_locations = [
    {
      name                           = "dest-efs"
      efs_file_system_arn            = aws_efs_file_system.source.arn
      ec2_config_subnet_arn          = module.vpc.private_subnet_arns[0]
      ec2_config_security_group_arns = [aws_security_group.efs_source.arn]
      tags                           = { project = "datasync-efs-cross-account" }
    }
  ]

  depends_on = [aws_efs_mount_target.source]
}

#############################
# DataSync Task
#############################

module "datasync_task" {
  source = "../../modules/datasync-task"

  datasync_tasks = [
    {
      name                     = "efs-to-efs-cross-account"
      source_location_arn      = aws_datasync_location_nfs.source.arn
      destination_location_arn = module.dest_efs_location.efs_locations["dest-efs"].arn
      options = {
        verify_mode       = "ONLY_FILES_TRANSFERRED"
        posix_permissions = "PRESERVE"
        uid               = "INT_VALUE"
        gid               = "INT_VALUE"
      }
      schedule_expression = "cron(0 6 ? * MON-FRI *)" # Run at 6:00 AM UTC weekdays
    }
  ]
}
