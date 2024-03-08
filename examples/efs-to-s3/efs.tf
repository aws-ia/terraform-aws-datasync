# random pet
resource "random_pet" "this" {
  length = 2
}

resource "aws_efs_file_system" "efs" {
  creation_token = "datasync-efs-${random_pet.this.id}"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # lifecycle_policy {
  #   transition_to_ia = "AFTER_30_DAYS"
  # }

  tags = {
    Name      = "datasync-efs-source"
    App       = "datasync"
    Managedby = "terraform"
  }
}

# Mount target for private subnets
resource "aws_efs_mount_target" "efs_subnet_mount_target" {
  for_each = {
    for index, private_subnet_id in module.vpc.private_subnets :
    index => private_subnet_id
  }
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.MyEfsSecurityGroup.id]
}

resource "aws_security_group" "MyEfsSecurityGroup" {
  name        = "MyEfsSecurityGroup"
  description = "My EFS security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.efs_security_group_egress_cidr_block]
  }

}
