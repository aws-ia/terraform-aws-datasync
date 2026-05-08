#############################
# Source EFS (Source Account)
#############################

resource "aws_efs_file_system" "source" {
  creation_token = "${local.name}-source-efs"
  encrypted      = true

  tags = {
    Name = "${local.name}-source-efs"
  }
}

resource "aws_efs_mount_target" "source" {
  file_system_id  = aws_efs_file_system.source.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs_source.id]
}

resource "aws_security_group" "efs_source" {
  name        = "${local.name}-source-efs-sg"
  description = "Security group for source EFS mount target"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    description = "NFS from VPC and peered VPC"
    cidr_blocks = [var.vpc_cidr_block, var.dest_vpc_cidr_block]
  }

  #checkov:skip=CKV_AWS_382: EFS mount target requires egress to AWS services for DataSync operations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-source-efs-sg"
  }
}

##################################
# Destination EFS (Dest Account)
##################################

resource "aws_efs_file_system" "destination" {
  provider       = aws.destination-account
  creation_token = "${local.name}-dest-efs"
  encrypted      = true

  tags = {
    Name = "${local.name}-dest-efs"
  }
}

resource "aws_efs_file_system_policy" "destination" {
  provider       = aws.destination-account
  file_system_id = aws_efs_file_system.destination.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountMount"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = aws_efs_file_system.destination.arn
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.source.account_id
          }
        }
      }
    ]
  })
}

resource "aws_efs_mount_target" "destination" {
  provider        = aws.destination-account
  file_system_id  = aws_efs_file_system.destination.id
  subnet_id       = module.dest_vpc.private_subnets[0]
  security_groups = [aws_security_group.efs_dest.id]
}

#############################
# Destination VPC
#############################

data "aws_availability_zones" "dest_available" {
  provider = aws.destination-account
  state    = "available"
}

module "dest_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=5.0.0"

  providers = {
    aws = aws.destination-account
  }

  name = "${local.name}-dest-vpc"
  cidr = var.dest_vpc_cidr_block

  azs             = [data.aws_availability_zones.dest_available.names[0]]
  private_subnets = [cidrsubnet(var.dest_vpc_cidr_block, 8, 1)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name}-dest-vpc"
  }
}

resource "aws_security_group" "efs_dest" {
  provider    = aws.destination-account
  name        = "${local.name}-dest-efs-sg"
  description = "Security group for destination EFS mount target"
  vpc_id      = module.dest_vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    description = "NFS from source VPC via peering"
    cidr_blocks = [var.vpc_cidr_block]
  }

  #checkov:skip=CKV_AWS_382: EFS mount target requires egress to AWS services for DataSync operations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-dest-efs-sg"
  }
}

#############################
# VPC Peering (Source <-> Dest)
#############################

data "aws_caller_identity" "destination" {
  provider = aws.destination-account
}

resource "aws_vpc_peering_connection" "source_to_dest" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = module.dest_vpc.vpc_id
  peer_owner_id = data.aws_caller_identity.destination.account_id

  tags = {
    Name = "${local.name}-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "dest_accept" {
  provider                  = aws.destination-account
  vpc_peering_connection_id = aws_vpc_peering_connection.source_to_dest.id
  auto_accept               = true

  tags = {
    Name = "${local.name}-peering"
  }
}

# Route from source private subnet to destination VPC via peering
resource "aws_route" "source_to_dest" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = var.dest_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source_to_dest.id

  depends_on = [aws_vpc_peering_connection_accepter.dest_accept]
}

# Route from destination private subnet to source VPC via peering
resource "aws_route" "dest_to_source" {
  provider                  = aws.destination-account
  route_table_id            = module.dest_vpc.private_route_table_ids[0]
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.source_to_dest.id

  depends_on = [aws_vpc_peering_connection_accepter.dest_accept]
}
