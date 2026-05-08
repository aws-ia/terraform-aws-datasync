<!-- BEGIN_TF_DOCS -->
# AWS EC2 DataSync Agent Terraform Sub-module

Deploys an AWS DataSync agent on an EC2 instance for transferring data between on-premises storage, other clouds, and AWS.

## Overview

This module creates an EC2 instance running the DataSync agent AMI (automatically retrieved from AWS SSM Parameter Store). The agent acts as a bridge between your storage systems and AWS services like S3.

## What This Module Creates

- EC2 instance with DataSync agent AMI
- Elastic IP for stable addressing
- Optional security group with required ports (80 for activation, 443 for management)
- Encrypted EBS root volume

## Agent AMI Versions

The module retrieves the latest DataSync agent AMI from SSM Parameter Store. Available paths:

- `/aws/service/datasync/ami/v1` — Basic mode (Amazon Linux 2)
- `/aws/service/datasync/ami/v2` — Basic mode (Amazon Linux 2023)
- `/aws/service/datasync/ami/v3` — Enhanced mode (Amazon Linux 2023) **(default)**

## Security Group Ports

When `create_security_group = true`, the following ports are configured:

- **Port 80 (HTTP)**: Ingress for agent activation (can be removed after activation)
- **Port 443 (HTTPS)**: Ingress for agent management
- **Port 22 (SSH)**: Ingress for administrative access (only when `ssh_key_name` is provided)
- **All ports**: Egress for AWS service communication

## Block Devices

The `root_block_device` variable allows customization of the root EBS volume:

- `disk_size`: Size in GiB (Default: 80)
- `volume_type`: EBS volume type (Default: gp3)
- `kms_key_id`: Optional KMS key ARN for encryption

## Next Steps

After deploying this module, use the [datasync-agent](../datasync-agent/) module to activate the agent with AWS DataSync.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.agent_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.agent_eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.datasync_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.agent_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.datasync_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | VPC Subnet ID to launch the EC2 instance | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID in which the DataSync agent security group will be created | `string` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | (Optional) Specific AMI ID for the DataSync agent. If not provided, the latest AMI is fetched from SSM Parameter Store using ssm\_parameter\_name. | `string` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for the agent EC2 instance. If not specified, will be determined by the subnet. | `string` | `null` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a Security Group for the EC2 DataSync agent. If false, provide a valid security\_group\_id. | `bool` | `false` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | CIDR blocks for agent egress traffic. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ingress_cidr_block_activation"></a> [ingress\_cidr\_block\_activation](#input\_ingress\_cidr\_block\_activation) | CIDR block to allow ingress port 80 for agent activation. Comma-separated for multiple. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | CIDR blocks to allow ingress into the DataSync agent for management access (port 443). Comma-separated for multiple. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the DataSync agent. | `string` | `"m6a.2xlarge"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EC2 DataSync agent instance | `string` | `"datasync-agent"` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Root block device configuration for the instance. | `map(any)` | <pre>{<br/>  "disk_size": 80,<br/>  "kms_key_id": null,<br/>  "volume_type": "gp3"<br/>}</pre> | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Existing Security Group ID to associate with the EC2 DataSync agent. Required if create\_security\_group is false. | `string` | `null` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | (Optional) EC2 Key pair name for SSH access to the DataSync agent. | `string` | `null` | no |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | SSM parameter path for the DataSync agent AMI. Valid paths: /aws/service/datasync/ami/v1 (Basic AL2), /aws/service/datasync/ami/v2 (Basic AL3), /aws/service/datasync/ami/v3 (Enhanced AL3). | `string` | `"/aws/service/datasync/ami/v3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | The AMI ID used for the DataSync agent EC2 instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the DataSync agent EC2 instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The Private IP address of the DataSync agent on EC2 |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The Public IP address of the created Elastic IP |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The Security Group ID associated with the DataSync agent |
<!-- END_TF_DOCS -->