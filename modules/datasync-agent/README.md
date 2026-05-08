<!-- BEGIN_TF_DOCS -->
# AWS DataSync Agent Terraform Sub-module

Activates a deployed DataSync agent with AWS, enabling it to be managed by the DataSync service.

## Overview

This module activates a DataSync agent by retrieving an activation key via HTTP and registering the agent with AWS DataSync. The activation process:

1. Waits for the agent EC2 instance to boot (configurable via `agent_boot_wait`)
2. Makes an HTTP request to the agent's IP address on port 80 to retrieve an activation key
3. Registers the agent with AWS DataSync using the activation key
4. Returns the agent ARN for use in DataSync locations and tasks

## Activation Requirements

- **Network Access**: The machine running Terraform must be able to reach the agent IP on port 80
- **Agent Ready**: The agent EC2 instance must be fully booted (the module includes a configurable wait)
- **Security Group**: Port 80 must be open from Terraform's network

## VPC Endpoint Support

For private connectivity, the module supports optional VPC endpoint configuration via `vpc_endpoint_id`, `private_link_endpoint`, `security_group_arns`, and `subnet_arns`.

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
| <a name="provider_http"></a> [http](#provider\_http) | >= 3.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datasync_agent.agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_agent) | resource |
| [time_sleep.wait_for_agent](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [http_http.activation](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activation_region"></a> [activation\_region](#input\_activation\_region) | AWS region for agent activation | `string` | n/a | yes |
| <a name="input_agent_ip_address"></a> [agent\_ip\_address](#input\_agent\_ip\_address) | IP address of the DataSync agent for activation. Terraform will make an HTTP GET request to port 80 on this IP. | `string` | n/a | yes |
| <a name="input_agent_name"></a> [agent\_name](#input\_agent\_name) | Name of the DataSync agent | `string` | n/a | yes |
| <a name="input_agent_boot_wait"></a> [agent\_boot\_wait](#input\_agent\_boot\_wait) | Time to wait for the DataSync agent to boot before attempting activation (e.g., '3m', '5m') | `string` | `"3m"` | no |
| <a name="input_agent_depends_on"></a> [agent\_depends\_on](#input\_agent\_depends\_on) | (Optional) Resource dependencies to ensure agent is ready before activation | `any` | `null` | no |
| <a name="input_private_link_endpoint"></a> [private\_link\_endpoint](#input\_private\_link\_endpoint) | (Optional) The IP address of the VPC endpoint the agent should connect to when retrieving an activation key | `string` | `null` | no |
| <a name="input_security_group_arns"></a> [security\_group\_arns](#input\_security\_group\_arns) | (Optional) The ARNs of the security groups used to protect your data transfer task subnets | `list(string)` | `[]` | no |
| <a name="input_subnet_arns"></a> [subnet\_arns](#input\_subnet\_arns) | (Optional) The ARNs of the subnets in which DataSync will create elastic network interfaces | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value pairs of resource tags to assign to the DataSync agent | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#input\_vpc\_endpoint\_id) | (Optional) The ID of the VPC endpoint that the agent has access to | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | Amazon Resource Name (ARN) of the DataSync agent |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | ID of the DataSync agent |
| <a name="output_agent_name"></a> [agent\_name](#output\_agent\_name) | Name of the DataSync agent |
<!-- END_TF_DOCS -->