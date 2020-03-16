# Allow ingress from Guacamole instance via ssh
# For: DevOps ssh access from Guacamole instance to Operations instance
resource "aws_security_group_rule" "operations_ingress_from_guacamole_via_ssh" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.guacamole.private_ip}/32"]
  from_port         = 22
  to_port           = 22
}

# Allow ingress from Guacamole instance via VNC
# For: Assessment team VNC access from Guacamole instance to Operations instance
resource "aws_security_group_rule" "operations_ingress_from_guacamole_via_vnc" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.guacamole.private_ip}/32"]
  from_port         = 5901
  to_port           = 5901
}

# Allow ingress from anywhere via the TCP ports specified in
# var.operations_subnet_inbound_tcp_ports_allowed
# For: Assessment team operational use
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_allowed_tcp_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.operations_subnet_inbound_tcp_ports_allowed)

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.value
  to_port           = each.value
}

# Allow ingress from anywhere via ephemeral TCP/UDP ports below 3389 (1024-3388)
# For: Assessment team operational use, but don't want to allow
#      public access to RDP on port 3389
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_ports_1024_thru_3388" {
  provider = aws.provisionassessment
  for_each = toset(local.tcp_and_udp)

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = each.value
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 1024
  to_port           = 3388
}

# Allow ingress from anywhere via ephemeral TCP/UDP ports 3390-5900
# For: Assessment team operational use, but don't want to allow
#      public access to RDP on port 3389 or VNC on port 5901
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_ports_3390_thru_5900" {
  provider = aws.provisionassessment
  for_each = toset(local.tcp_and_udp)

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = each.value
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 3390
  to_port           = 5900
}

# Allow ingress from anywhere via ephemeral TCP/UDP ports above 5901 (5902-65535)
# For: Assessment team operational use, but don't want to allow
#      public access to VNC on port 5901
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_ports_5902_thru_65535" {
  provider = aws.provisionassessment
  for_each = toset(local.tcp_and_udp)

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = each.value
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 5902
  to_port           = 65535
}

# Allow ingress from anywhere via ICMP
# For: Assessment team operational use (e.g. ping responses)
resource "aws_security_group_rule" "operations_ingress_from_anywhere_via_icmp" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.operations.id
  type              = "ingress"
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
}

# Allow egress to anywhere via any protocol and port
# For: Assessment team operational use
resource "aws_security_group_rule" "operations_egress_to_anywhere_via_any_port" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.operations.id
  type              = "egress"
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
}
