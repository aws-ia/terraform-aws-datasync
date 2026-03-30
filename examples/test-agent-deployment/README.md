<!-- BEGIN_TF_DOCS -->
# Test Agent Deployment Example

End-to-end example that deploys and activates a DataSync Enhanced mode agent on EC2.

## What This Example Creates

- VPC with a public subnet
- EC2 instance running the DataSync Enhanced mode agent AMI
- Elastic IP for the agent
- Security group with required ports
- Activated DataSync agent registered with AWS

## Usage

```bash
terraform init
terraform apply
```

To clean up:

```bash
terraform destroy
```

## Notes

- The agent takes approximately 3 minutes to boot before activation
- The `m6a.2xlarge` instance type is recommended by AWS for Enhanced mode agents
- Port 80 must be reachable from where Terraform is running for agent activation

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datasync_agent_activation"></a> [datasync\_agent\_activation](#module\_datasync\_agent\_activation) | ../../modules/datasync-agent-activation | n/a |
| <a name="module_datasync_agent_ec2"></a> [datasync\_agent\_ec2](#module\_datasync\_agent\_ec2) | ../../modules/ec2-datasync-agent | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | >=5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for resources | `string` | `"us-east-1"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of EC2 key pair for SSH access (optional) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | ARN of the activated DataSync agent |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | ID of the activated DataSync agent |
| <a name="output_agent_instance_id"></a> [agent\_instance\_id](#output\_agent\_instance\_id) | EC2 instance ID of the DataSync agent |
| <a name="output_agent_private_ip"></a> [agent\_private\_ip](#output\_agent\_private\_ip) | Private IP of the DataSync agent |
| <a name="output_agent_public_ip"></a> [agent\_public\_ip](#output\_agent\_public\_ip) | Public IP of the DataSync agent |
<!-- END_TF_DOCS -->