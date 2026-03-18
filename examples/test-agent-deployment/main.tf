# Simple test to deploy and activate a DataSync Enhanced mode agent

locals {
  name = "test-datasync-agent"
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a simple VPC for testing
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=5.0.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = [data.aws_availability_zones.available.names[0]]
  public_subnets = ["10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name}-vpc"
  }
}

# Deploy the DataSync agent on EC2
module "datasync_agent_ec2" {
  source = "../../modules/ec2-datasync-agent"

  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  name          = local.name
  instance_type = "m6a.2xlarge"

  create_security_group         = true
  ingress_cidr_blocks           = "10.0.0.0/16"
  ingress_cidr_block_activation = "0.0.0.0/0"

  ssh_key_name = var.ssh_key_name
}

# Activate the agent
module "datasync_agent_activation" {
  source = "../../modules/datasync-agent-activation"

  agent_name       = local.name
  agent_ip_address = module.datasync_agent_ec2.public_ip
  activation_region = var.aws_region

  tags = {
    Environment = "test"
    Purpose     = "agent-deployment-test"
  }

  agent_depends_on = [module.datasync_agent_ec2]
}
