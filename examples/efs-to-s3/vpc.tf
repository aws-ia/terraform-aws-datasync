#############################
# Create VPC and Subnets 
#############################
resource "random_pet" "name" {
  prefix = "aws-ia"
  length = 1
}

data "aws_availability_zones" "available" {}

#VPC flow logs enabled. Skipping tfsec bug https://github.com/aquasecurity/tfsec/issues/1941
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = var.vpc_cidr_block

  azs             = slice(data.aws_availability_zones.available.names, 0, (var.subnet-count))
  private_subnets = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)] # For Private subnets
  public_subnets  = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc_cidr_block, 8, sum([subnet, var.subnet-count]))]
  name            = "${random_pet.name.id}-gateway-vpc"

  enable_dns_hostnames                 = true
  create_igw                           = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}