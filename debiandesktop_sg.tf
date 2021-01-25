# Security group for the Debian desktop instances in the operations
# subnet
resource "aws_security_group" "debiandesktop" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = merge(
    var.tags,
    {
      "Name" = "Debian Desktop"
    },
  )
}

# Allow ingress from Guacamole instance via ssh
# For: DevOps ssh access from Guacamole instance to Debian desktop instance
resource "aws_security_group_rule" "debiandesktop_ingress_from_guacamole_via_ssh" {
  count    = lookup(var.operations_instance_counts, "debiandesktop", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.debiandesktop.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.desktop_gateway.id
  from_port                = 22
  to_port                  = 22
}

# Allow ingress from Guacamole instance via VNC
# For: Assessment team VNC access from Guacamole instance to Debian desktop
# instance
resource "aws_security_group_rule" "debiandesktop_ingress_from_guacamole_via_vnc" {
  count    = lookup(var.operations_instance_counts, "debiandesktop", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.debiandesktop.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.desktop_gateway.id
  from_port                = 5901
  to_port                  = 5901
}

# Allow egress from Debian desktop instances via Nessus web GUI port (8834)
# For: Operator Nessus web access from Debian desktop instances
#
# NOTE: This rule will only be created if there is at least one Nessus instance
# and at least one Debian Desktop instance.
resource "aws_security_group_rule" "debiandesktop_egress_to_nessus_via_gui_port" {
  count    = lookup(var.operations_instance_counts, "debiandesktop", 0) * lookup(var.operations_instance_counts, "nessus", 0) > 0 ? 1 : 0
  provider = aws.provisionassessment

  security_group_id = aws_security_group.debiandesktop.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = [for instance in aws_instance.nessus : format("%s/32", instance.private_ip)]
  from_port         = 8834
  to_port           = 8834
}

# Allow egress to anywhere via HTTP and HTTPS
# For: Operator web access, package downloads and updates
resource "aws_security_group_rule" "debiandesktop_egress_to_anywhere_via_allowed_ports" {
  for_each = lookup(var.operations_instance_counts, "debiandesktop", 0) > 0 ? toset(["80", "443"]) : toset([])
  provider = aws.provisionassessment

  security_group_id = aws_security_group.debiandesktop.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = each.key
  to_port           = each.key
}
