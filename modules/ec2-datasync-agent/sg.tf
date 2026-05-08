######################
## Security Group  ##
######################

resource "aws_security_group" "agent_sg" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name}-sg"
  description = "Security group for DataSync agent"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-sg"
  }
}

# Allow HTTP (port 80) for agent activation
# This is only needed during activation - can be removed after
resource "aws_security_group_rule" "http" {
  count             = var.create_security_group ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = split(",", var.ingress_cidr_block_activation)
  security_group_id = aws_security_group.agent_sg[0].id
  description       = "Allow HTTP for agent activation"
}

# Allow HTTPS (port 443) for agent management and data transfer
resource "aws_security_group_rule" "https" {
  count             = var.create_security_group ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = split(",", var.ingress_cidr_blocks)
  security_group_id = aws_security_group.agent_sg[0].id
  description       = "Allow HTTPS for agent management"
}

# Allow SSH (port 22) for administrative access (optional)
resource "aws_security_group_rule" "ssh" {
  count             = var.create_security_group && var.ssh_key_name != null ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = split(",", var.ingress_cidr_blocks)
  security_group_id = aws_security_group.agent_sg[0].id
  description       = "Allow SSH for administrative access"
}

# Allow all outbound traffic for AWS service communication
resource "aws_security_group_rule" "egress" {
  count             = var.create_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.egress_cidr_blocks]
  security_group_id = aws_security_group.agent_sg[0].id
  description       = "Allow all outbound traffic"
}
