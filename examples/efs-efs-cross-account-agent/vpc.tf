#############################
# VPC in Source Account
#############################
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=5.0.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr_block

  azs             = [data.aws_availability_zones.available.names[0]]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  create_igw           = true

  tags = {
    Name = "${local.name}-vpc"
  }
}
