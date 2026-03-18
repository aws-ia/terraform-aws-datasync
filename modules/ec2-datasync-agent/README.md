# AWS EC2 DataSync Agent Terraform Module

Deploys an AWS DataSync agent on EC2 for transferring data between on-premises storage and AWS.

## Overview

This module creates an EC2 instance running the DataSync agent software. The agent acts as a bridge between your on-premises NFS/SMB storage and AWS services like S3. It handles data transfer, compression, encryption, and network optimization.

## Agent Modes

DataSync agents run in two modes:

- **BASIC mode**: Standard performance for most workloads
- **ENHANCED mode**: Higher performance for S3 transfers with NFS/SMB sources
  - Recommended instance type: `m6a.2xlarge`
  - Supports unlimited numbers of files/objects
  - Better monitoring with structured JSON logging

## What This Module Creates

- EC2 instance with DataSync agent AMI (automatically retrieved from SSM)
- Elastic IP for stable addressing
- Optional security group with required ports (80 for activation, 443 for management)
- Encrypted EBS root volume

## Usage

### Basic Example

```hcl
module "datasync_agent" {
  source = "../../modules/ec2-datasync-agent"
  
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"
  name      = "my-datasync-agent"
  
  create_security_group = true
}
```

### Enhanced Mode Example

```hcl
module "datasync_agent_enhanced" {
  source = "../../modules/ec2-datasync-agent"
  
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  name          = "datasync-enhanced-agent"
  agent_mode    = "ENHANCED"
  instance_type = "m6a.2xlarge"  # AWS recommended for Enhanced mode
  
  create_security_group         = true
  ingress_cidr_blocks           = "10.0.0.0/16"
  ingress_cidr_block_activation = "0.0.0.0/0"
}
```

### With Existing Security Group

```hcl
module "datasync_agent" {
  source = "../../modules/ec2-datasync-agent"
  
  vpc_id            = "vpc-12345678"
  subnet_id         = "subnet-12345678"
  name              = "my-datasync-agent"
  
  create_security_group = false
  security_group_id     = "sg-12345678"
}
```

## Block Devices

The `root_block_device` variable allows customization of the root EBS volume:

- `kms_key_id`: Optional KMS key for encryption
- `disk_size`: Size in GiB (Default: 80)
- `volume_type`: EBS volume type (Default: gp3)

Example:

```hcl
root_block_device = {
  disk_size   = 100
  volume_type = "gp3"
  kms_key_id  = "arn:aws:kms:<region>:<account-id>:key/<key-id>"
}
```

## Security Group Ports

When `create_security_group = true`, the following ports are configured:

- **Port 80 (HTTP)**: Ingress for agent activation (can be removed after activation)
- **Port 443 (HTTPS)**: Ingress for agent management
- **All ports**: Egress for AWS service communication

## Next Steps

After deploying this module:

1. Use the `public_ip` output to activate the agent (see `datasync-agent` module)
2. Create DataSync locations pointing to your on-premises storage
3. Create DataSync tasks to transfer data

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.7 |
| aws | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | The VPC ID in which the DataSync agent security group will be created | `string` | n/a | yes |
| subnet_id | VPC Subnet ID to launch the EC2 instance | `string` | n/a | yes |
| name | Name of the EC2 DataSync agent instance | `string` | `"datasync-agent"` | no |
| instance_type | The instance type to use for the DataSync agent | `string` | `"m6a.2xlarge"` | no |
| agent_mode | Agent mode - BASIC or ENHANCED | `string` | `"ENHANCED"` | no |
| availability_zone | Availability zone for the agent EC2 instance | `string` | `null` | no |
| create_security_group | Create a Security Group for the EC2 DataSync agent | `bool` | `false` | no |
| security_group_id | Existing Security Group ID to associate with EC2 DataSync agent | `string` | `null` | no |
| ingress_cidr_blocks | CIDR blocks to allow ingress for management access | `string` | `"10.0.0.0/16"` | no |
| ingress_cidr_block_activation | CIDR block to allow port 80 for activation | `string` | `"0.0.0.0/0"` | no |
| egress_cidr_blocks | CIDR blocks for agent egress traffic | `string` | `"0.0.0.0/0"` | no |
| ssh_key_name | EC2 Key pair name for SSH access | `string` | `null` | no |
| root_block_device | Root block device configuration | `map(any)` | `{ disk_size = 80, kms_key_id = null, volume_type = "gp3" }` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the DataSync agent EC2 instance |
| public_ip | The Public IP address of the created Elastic IP |
| private_ip | The Private IP address of the DataSync agent on EC2 |
| ami_id | The AMI ID used for the DataSync agent EC2 instance |
| security_group_id | The Security Group ID associated with the DataSync agent |

## Notes

- The AMI is automatically retrieved from AWS SSM Parameter Store
- AMI changes are ignored by default to prevent unexpected instance replacement
- To update the AMI: `terraform apply -replace="module.datasync_agent.aws_instance.datasync_agent"`
- The agent must be activated after deployment using the `datasync-agent` module
