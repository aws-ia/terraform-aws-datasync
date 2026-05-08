<!-- BEGIN_TF_DOCS -->
# EFS-to-EFS Cross-Account DataSync with EC2 Agent

End-to-end example that deploys a DataSync EC2 agent and syncs data between EFS file systems across two AWS accounts.

## What This Example Creates

**Source Account:**
- VPC with public and private subnets
- EC2 instance running the DataSync Basic mode agent AMI
- Elastic IP and security group for the agent
- Activated DataSync agent registered with AWS
- Source EFS file system with mount target
- DataSync NFS source location (cross-account EFS accessed via agent)
- DataSync EFS destination location (local EFS)
- DataSync task for scheduled EFS-to-EFS sync
- VPC peering connection to destination account

**Destination Account:**
- VPC with private subnet
- Destination EFS file system with mount target and cross-account file system policy

## Architecture

For cross-account EFS-to-EFS transfers, DataSync requires:
- A **Basic mode agent** with network access to both EFS file systems
- The remote (cross-account) EFS configured as an **NFS location** (not a native EFS location)
- The local EFS configured as a native **EFS location**
- **VPC peering** for cross-account network connectivity

Enhanced mode is not supported for this transfer type — NFS locations only work with Basic mode tasks.

## Prerequisites

Configure AWS credentials for both accounts in `~/.aws/credentials`:

```
[source-account]
aws_access_key_id = xxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxxx

[destination-account]
aws_access_key_id = xxxxxxxxxx
aws_secret_access_key = xxxxxxxxxxxxx
```

## Usage

```bash
terraform init
terraform apply -var="source_account_profile=source-account" -var="dest_account_profile=destination-account"
```

## Notes

- The agent takes approximately 3 minutes to boot before activation
- Uses the Basic mode agent AMI (Enhanced mode agents cannot run NFS-based tasks)
- Port 80 must be reachable from where Terraform is running for agent activation
- The destination EFS file system policy grants cross-account NFS mount access
- VPC CIDRs must not overlap (default: 10.0.0.0/16 source, 10.1.0.0/16 destination)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |
| <a name="provider_aws.destination-account"></a> [aws.destination-account](#provider\_aws.destination-account) | >= 6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datasync_agent"></a> [datasync\_agent](#module\_datasync\_agent) | ../../modules/datasync-agent | n/a |
| <a name="module_datasync_agent_ec2"></a> [datasync\_agent\_ec2](#module\_datasync\_agent\_ec2) | ../../modules/ec2-datasync-agent | n/a |
| <a name="module_datasync_task"></a> [datasync\_task](#module\_datasync\_task) | ../../modules/datasync-task | n/a |
| <a name="module_dest_efs_location"></a> [dest\_efs\_location](#module\_dest\_efs\_location) | ../../modules/datasync-locations | n/a |
| <a name="module_dest_vpc"></a> [dest\_vpc](#module\_dest\_vpc) | terraform-aws-modules/vpc/aws | >=5.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | >=5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_datasync_location_nfs.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_nfs) | resource |
| [aws_efs_file_system.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_mount_target.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_route.dest_to_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.source_to_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_security_group.efs_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_peering_connection.source_to_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.dest_accept](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_ami.datasync_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_availability_zones.dest_available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dest_account_profile"></a> [dest\_account\_profile](#input\_dest\_account\_profile) | AWS profile for the destination account (contains destination EFS) | `string` | `"destination-account"` | no |
| <a name="input_dest_vpc_cidr_block"></a> [dest\_vpc\_cidr\_block](#input\_dest\_vpc\_cidr\_block) | VPC CIDR block for the destination account (must not overlap with source) | `string` | `"10.1.0.0/16"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for resources | `string` | `"us-east-1"` | no |
| <a name="input_source_account_profile"></a> [source\_account\_profile](#input\_source\_account\_profile) | AWS profile for the source account (contains source EFS, EC2 agent, and DataSync resources) | `string` | `"source-account"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of EC2 key pair for SSH access to the agent (optional) | `string` | `null` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR block for the source account | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | ARN of the activated DataSync agent |
| <a name="output_agent_public_ip"></a> [agent\_public\_ip](#output\_agent\_public\_ip) | Public IP of the DataSync agent EC2 instance |
| <a name="output_datasync_task"></a> [datasync\_task](#output\_datasync\_task) | DataSync task |
| <a name="output_dest_efs_location_arn"></a> [dest\_efs\_location\_arn](#output\_dest\_efs\_location\_arn) | DataSync destination EFS location ARN |
| <a name="output_source_nfs_location_arn"></a> [source\_nfs\_location\_arn](#output\_source\_nfs\_location\_arn) | DataSync source NFS location ARN (cross-account EFS) |
<!-- END_TF_DOCS -->