#######################################
#Providers for Source and Dest Accounts
#######################################

provider "aws" {
  profile = var.owner_profile
  region  = var.region
}

provider "aws" {
  alias   = "dest"
  region  = var.region
  profile = var.accepter_profile
}

######################################
# Defaults and Locals
######################################

resource "random_pet" "name" {
  prefix = "aws-ia"
  length = 1
}

#########################
# Create DataSync Agent
#########################

module "datasync" {
  depends_on = [module.ec2_datasync_agent]
  source     = "../../modules/aws-datasync"

  providers = {          # Optional - Specify provider for Cross Account (For Cross account use cases)
    aws.dst = aws.dest
    #aws.src  = aws
  }

  datasync_name                      = random_pet.name.id
  agent_ip_address                   = module.ec2_datasync_agent.public_ip
  create_vpc_endpoint                = true
  create_vpc_endpoint_security_group = true #if false define vpc_endpoint_security_group_id 
  dest_vpc_id                        = var.dest_vpc_id
  vpc_endpoint_subnet_ids            = var.vpc_endpoint_subnet_ids
  datasync_private_ip_address        = module.ec2_datasync_agent.private_ip
}

###########################
# Create EC2 Datasync
###########################

module "ec2_datasync_agent" {

  source            = "../../modules/ec2-datasync-agent"
  source_vpc_id     = var.source_vpc_id
  source_subnet_id  = var.source_subnet_id
  name              = "${random_pet.name.id}-datasync"
  availability_zone = var.aws_availability_zone
  ssh_key_name      = var.ssh_key_name

  #If create security_group = true , define ingress cidr blocks, if not use security_group_id
  create_security_group         = true
  ingress_cidr_blocks           = var.ingress_cidr_blocks
  ingress_cidr_block_activation = var.ingress_cidr_block_activation

  # Cache and Root Volume encryption key

  root_block_device = {
    kms_key_id = aws_kms_key.datasync.arn
  }

}

resource "aws_kms_key" "datasync" {
  description             = "KMS key for encrypting S3 buckets and EBS volumes"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# #####################################
# # Create Destination VPC and Subnets 
# #####################################

# data "aws_availability_zones" "available" {}

# #VPC flow logs enabled. Skipping tfsec bug https://github.com/aquasecurity/tfsec/issues/1941
# #tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = ">=5.0.0"

#   cidr = var.dest_vpc_cidr_block

#   azs             = slice(data.aws_availability_zones.available.names, 0, (var.subnet-count))
#   private_subnets = [for subnet in range(var.subnet-count) : cidrsubnet(var.dest_vpc_cidr_block, 8, subnet)] # For Private subnets
#   public_subnets  = [for subnet in range(var.subnet-count) : cidrsubnet(var.dest_vpc_cidr_block, 8, sum([subnet, var.subnet-count]))]
#   name            = "${random_pet.name.id}-dest-datasync-vpc"

#   enable_dns_hostnames                 = true
#   create_igw                           = true
#   enable_flow_log                      = true
#   create_flow_log_cloudwatch_log_group = true
#   create_flow_log_cloudwatch_iam_role  = true
#   flow_log_max_aggregation_interval    = 60
# }

#####################
#Create VPC Peering 
#####################

# Note: For cross account datasync, network communication from source account 
# to destination account is established using VPC peering connection. 

data "aws_vpc" "dest" {
  provider = aws.dest
  id       = var.dest_vpc_id
}

locals {
  dest_account_id = element(split(":", data.aws_vpc.dest.arn), 4)
}

resource "aws_vpc_peering_connection" "source" {
  vpc_id        = var.source_vpc_id
  peer_vpc_id   = data.aws_vpc.dest.id
  peer_owner_id = local.dest_account_id

  #tags {
  #  Name = "peer_to_${var.accepter_profile}"
  #}
}

resource "aws_vpc_peering_connection_accepter" "dest" {
  provider                  = aws.dest
  vpc_peering_connection_id = aws_vpc_peering_connection.source.id
  auto_accept               = true

  #tags {
  #  Name = "peer_to_${var.owner_profile}"
  #}
}

data "aws_vpc" "source" {
  id = var.source_vpc_id
}


data "aws_route_tables" "dest" {
  provider = aws.dest
  vpc_id   = data.aws_vpc.dest.id
}

data "aws_route_tables" "source" {
  vpc_id = var.source_vpc_id
}


resource "aws_route" "source" {
  count                     = length(data.aws_route_tables.source.ids)
  route_table_id            = data.aws_route_tables.source.ids[count.index]
  destination_cidr_block    = data.aws_vpc.dest.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source.id
}

resource "aws_route" "dest" {
  provider                  = aws.dest
  count                     = length(data.aws_route_tables.dest.ids)
  route_table_id            = data.aws_route_tables.dest.ids[count.index]
  destination_cidr_block    = data.aws_vpc.source.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source.id
}

############################

locals {
  ssh_key_name = length(var.ssh_public_key_path) > 0 ? aws_key_pair.ec2_datasync_key_pair["ec2_datasync_key_pair"].key_name : null
}

resource "aws_key_pair" "ec2_datasync_key_pair" {

  for_each = length(var.ssh_public_key_path) > 0 ? toset(["ec2_datasync_key_pair"]) : toset([])

  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

