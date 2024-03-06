##################
# DataSync Agent
##################

resource "aws_datasync_agent" "this" {
  provider              = aws.dst # Optional - Specify provider for Cross Account (For Cross account use cases)
  ip_address            = var.agent_ip_address
  security_group_arns   = [data.aws_security_group.sg_arn.arn]
  subnet_arns           = [data.aws_subnet.subnet_arn.arn]
  vpc_endpoint_id       = aws_vpc_endpoint.datasync_vpce.id
  private_link_endpoint = data.aws_network_interface.test.private_ip
  name                  = var.datasync_name

  lifecycle {
    create_before_destroy = false
  }
}

##########################
## Create VPC Endpoint
##########################

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "datasync_vpce" {

  provider = aws.dst # Optional - Specify provider for Cross Account (For Cross account use cases) 

  vpc_id            = var.dest_vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.datasync"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.create_vpc_endpoint_security_group ? aws_security_group.vpce_sg["vpce_sg"].id : var.vpc_endpoint_security_group_id
  ]

  subnet_ids = var.vpc_endpoint_subnet_ids

  private_dns_enabled = var.vpc_endpoint_private_dns_enabled

  tags = {
    Name = "datasync-endpoint"
  }

  lifecycle {
    # VPC Subnet IDs must be non empty
    precondition {
      condition     = try(length(var.vpc_endpoint_subnet_ids[0]) > 7, false)
      error_message = "Variable vpc_endpoint_subnet_ids must contain at least one valid subnet to create VPC Endpoint Security Group"
    }
  }

}

#######################################################
# Datasync VPC Endpoint ENI, Subnet and Security Group
#######################################################

data "aws_network_interface" "test" {
  provider = aws.dst # Optional - Specify provider for Cross Account (For Cross account use cases)
  id       = tolist(aws_vpc_endpoint.datasync_vpce.network_interface_ids)[0]
}

data "aws_subnet" "subnet_arn" {
  provider = aws.dst # Optional - Specify provider for Cross Account (For Cross account use cases)
  id       = tolist(aws_vpc_endpoint.datasync_vpce.subnet_ids)[0]
}

data "aws_security_group" "sg_arn" {
  provider = aws.dst # Optional - Specify provider for Cross Account (For Cross account use cases)
  id       = tolist(aws_vpc_endpoint.datasync_vpce.security_group_ids)[0]
}