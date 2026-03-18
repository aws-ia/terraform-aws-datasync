# AWS DataSync Agent Activation Module

Activates a deployed DataSync agent with AWS, enabling it to be managed by the DataSync service.

## Overview

This module creates an `aws_datasync_agent` resource that activates a DataSync agent by contacting it on port 80 (HTTP). The activation process:

1. Terraform makes an HTTP GET request to the agent's IP address on port 80
2. The agent responds with an activation key
3. Terraform registers the agent with AWS DataSync service
4. AWS returns an agent ARN that can be used in DataSync locations
5. The agent turns off the HTTP server on port 80 after activation

## Usage

### Basic Activation

```hcl
module "datasync_agent" {
  source = "../../modules/datasync-agent"
  
  agent_name       = "my-datasync-agent"
  agent_ip_address = module.ec2_datasync_agent.public_ip
}
```

### With VPC Endpoint (Private Connectivity)

```hcl
module "datasync_agent" {
  source = "../../modules/datasync-agent"
  
  agent_name            = "my-datasync-agent"
  agent_ip_address      = module.ec2_datasync_agent.public_ip
  vpc_endpoint_id       = aws_vpc_endpoint.datasync.id
  private_link_endpoint = data.aws_network_interface.datasync_vpce.private_ip
  security_group_arns   = [aws_security_group.datasync.arn]
  subnet_arns           = [aws_subnet.private.arn]
  
  tags = {
    Environment = "production"
    Project     = "data-migration"
  }
}
```

### Complete Example with EC2 Agent

```hcl
# Deploy the agent EC2 instance
module "ec2_datasync_agent" {
  source = "../../modules/ec2-datasync-agent"
  
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"
  name      = "datasync-agent"
  
  create_security_group = true
}

# Activate the agent
module "datasync_agent" {
  source = "../../modules/datasync-agent"
  
  agent_name       = "my-datasync-agent"
  agent_ip_address = module.ec2_datasync_agent.public_ip
  
  # Ensure EC2 instance is ready before activation
  agent_depends_on = [module.ec2_datasync_agent]
}

# Use the agent ARN in a location
module "nfs_location" {
  source = "../../modules/datasync-locations"
  
  nfs_locations = [{
    name            = "onprem-nfs"
    server_hostname = "192.168.1.100"
    subdirectory    = "/exports/data"
    agent_arns      = [module.datasync_agent.agent_arn]
  }]
}
```

## Activation Requirements

For successful activation:

1. **Network Access**: Terraform must be able to reach the agent IP on port 80
2. **Agent Ready**: The agent EC2 instance must be fully booted and running
3. **Security Group**: Port 80 must be open from Terraform's IP address
4. **Timing**: May need to wait 2-3 minutes after EC2 instance creation for agent to be ready

## Troubleshooting

### Activation Timeout

If activation times out:
- Verify security group allows port 80 from Terraform's IP
- Check agent EC2 instance is running and healthy
- Wait a few minutes for agent to fully boot
- Verify network connectivity to the agent IP

### VPC Endpoint Issues

If using VPC endpoint:
- Ensure VPC endpoint is created and available
- Verify security groups allow traffic between agent and VPC endpoint
- Check subnet routing allows agent to reach VPC endpoint

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.7 |
| aws | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent_name | Name of the DataSync agent | `string` | n/a | yes |
| agent_ip_address | IP address of the DataSync agent for activation | `string` | n/a | yes |
| vpc_endpoint_id | The ID of the VPC endpoint that the agent has access to | `string` | `null` | no |
| private_link_endpoint | The IP address of the VPC endpoint for activation | `string` | `null` | no |
| security_group_arns | ARNs of security groups for data transfer task subnets | `list(string)` | `[]` | no |
| subnet_arns | ARNs of subnets for DataSync elastic network interfaces | `list(string)` | `[]` | no |
| tags | Key-value pairs of resource tags | `map(string)` | `{}` | no |
| agent_depends_on | Resource dependencies to ensure agent is ready | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent_arn | Amazon Resource Name (ARN) of the DataSync agent |
| agent_id | ID of the DataSync agent |
| agent_name | Name of the DataSync agent |

## Notes

- The agent ARN is required when creating NFS or SMB DataSync locations
- A location can have up to 4 Basic mode agents and 4 Enhanced mode agents
- The agent must match the task mode (Basic task uses Basic agent, Enhanced task uses Enhanced agent)
- After activation, port 80 is no longer needed and can be removed from security groups
