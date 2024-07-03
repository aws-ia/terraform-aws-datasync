resource "aws_kms_key" "efs-kms" {
  description              = "KMS key for encrypting EFS File System"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  enable_key_rotation      = true
}

resource "aws_kms_key_policy" "efs-kms-key-policy" {
  key_id = aws_kms_key.efs-kms.id
  policy = jsonencode({
    Id = "SourceKMSKeyPolicy"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:PutKeyPolicy",
          "kms:Get*",
          "kms:List*"
        ]
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }

        Resource = "${aws_kms_key.efs-kms.arn}"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_efs_file_system" "efs" {
  creation_token = "datasync-efs-${random_pet.prefix.id}"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  kms_key_id       = aws_kms_key.efs-kms.arn

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
    description = "NFS-TCP"
    cidr_blocks = [var.vpc_cidr_block]
  }
  #outbound connections for EFS Mount Target to reach to AWS services
  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "EFS Egress Traffic"
    cidr_blocks = [var.efs_security_group_egress_cidr_block]
  }

}
