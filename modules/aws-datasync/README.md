<!-- BEGIN_TF_DOCS -->
# AWS DataSync Terraform sub-module

Deploys a DataSync Agent on AWS. Agent deployment is required for syncing data from on-premise to AWS or between AWS cloud storage services. Requires the Datasync VM to be deployed first using the module [vmware-datasync-agent](https://github.com/prabirsekhri/terraform-aws-datasync/tree/develop/modules/vmware-datasync-agent) or the [ec2-datasync-agent](https://github.com/prabirsekhri/terraform-aws-datasync/tree/develop/modules/ec2-datasync-agent). For an end to end examples refer to the examples directory.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datasync_agent.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_agent) | resource |
| [aws_security_group.vpce_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.datasync_vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_ip_address"></a> [agent\_ip\_address](#input\_agent\_ip\_address) | IP Address of Datasync | `string` | n/a | yes |
| <a name="input_create_vpc_endpoint"></a> [create\_vpc\_endpoint](#input\_create\_vpc\_endpoint) | Create an Interface VPC endpoint for Datasync | `bool` | `false` | no |
| <a name="input_create_vpc_endpoint_security_group"></a> [create\_vpc\_endpoint\_security\_group](#input\_create\_vpc\_endpoint\_security\_group) | Create a Security Group for the VPC Endpoint for Datasync Agent. | `bool` | `false` | no |
| <a name="input_datasync_name"></a> [datasync\_name](#input\_datasync\_name) | Datasync Name | `string` | n/a | yes |
| <a name="input_datasync_private_ip_address"></a> [datasync\_private\_ip\_address](#input\_datasync\_private\_ip\_address) | Inbound IP address of Datasync agent VM appliance for Security Group associated with VPC Endpoint. Must be set if create\_vpc\_endpoint=true | `string` | `null` | no |
| <a name="input_datasync_vpc_endpoint"></a> [datasync\_vpc\_endpoint](#input\_datasync\_vpc\_endpoint) | Existing VPC endpoint address to be used when activating your gateway. This variable value will be ignored if setting create\_vpc\_endpoint=true. | `string` | `null` | no |
| <a name="input_vpc_endpoint_private_dns_enabled"></a> [vpc\_endpoint\_private\_dns\_enabled](#input\_vpc\_endpoint\_private\_dns\_enabled) | Enable private DNS for VPC Endpoint | `bool` | `false` | no |
| <a name="input_vpc_endpoint_security_group_id"></a> [vpc\_endpoint\_security\_group\_id](#input\_vpc\_endpoint\_security\_group\_id) | Optionally provide an existing Security Group ID to associate with the VPC Endpoint. Must be set if create\_vpc\_endpoint\_security\_group=false | `string` | `null` | no |
| <a name="input_vpc_endpoint_subnet_ids"></a> [vpc\_endpoint\_subnet\_ids](#input\_vpc\_endpoint\_subnet\_ids) | Provide existing subnet IDs to associate with the VPC Endpoint. Must provide a valid values if create\_vpc\_endpoint=true. | `list(string)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id for creating a VPC endpoint. Must provide a valid value if create\_vpc\_endpoint=true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datasync"></a> [datasync](#output\_datasync) | Datasync Module |
<!-- END_TF_DOCS -->