locals {
  #ingress_cidr_blocks_list           = split(",", var.ingress_cidr_blocks)
  egress_cidr_blocks_list            = split(",", var.egress_cidr_blocks)
  ingress_cidr_block_activation_list = split(",", var.ingress_cidr_block_activation)
}

resource "aws_security_group" "ec2_sg" {

  for_each = var.create_security_group == true ? toset(["ec2_sg"]) : toset([])

  name        = "${var.name}.security-group"
  description = "Security group with custom ports open within VPC for client connectivity and communication with AWS."
  vpc_id      = var.source_vpc_id
}

resource "aws_security_group_rule" "http" {
  for_each          = var.create_security_group == true ? toset(["http"]) : toset([])
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  description       = "HTTP required only for activation purposes. The port is closed after activation."
  cidr_blocks       = local.ingress_cidr_block_activation_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

#outbound connections for Storage Gateway for activation
#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "egress" {
  for_each          = var.create_security_group == true ? toset(["egress"]) : toset([])
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Storage Gateway egress traffic for activation"
  cidr_blocks       = local.egress_cidr_blocks_list
  security_group_id = aws_security_group.ec2_sg["ec2_sg"].id
}

