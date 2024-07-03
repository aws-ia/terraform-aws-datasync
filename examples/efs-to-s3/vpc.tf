#############################
# Create VPC and Subnets 
#############################
data "aws_availability_zones" "available" {}

#VPC flow logs enabled. Skipping tfsec bug https://github.com/aquasecurity/tfsec/issues/1941
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=26c38a66f12e7c6c93b6a2ba127ad68981a48671"  # commit hash of version 5.0.0 

  cidr = var.vpc_cidr_block


  azs             = slice(data.aws_availability_zones.available.names, 0, (var.subnet-count))
  private_subnets = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)] # For Private subnets
  public_subnets  = [for subnet in range(var.subnet-count) : cidrsubnet(var.vpc_cidr_block, 8, sum([subnet, var.subnet-count]))]
  name            = "${random_pet.prefix.id}-datasync-vpc"

  enable_dns_hostnames                 = true
  create_igw                           = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}
