# Security group for the instances accessible by Guacamole
resource "aws_security_group" "guacamole_accessible" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "Guacamole accessible"
  }
}

# Allow ingress from Guacamole instances via SSH
resource "aws_security_group_rule" "ingress_from_guacamole_via_ssh" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole_accessible.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 22
  to_port                  = 22
}

# Allow ingress from Guacamole instances via RDP (TCP)
resource "aws_security_group_rule" "ingress_from_guacamole_via_rdp_over_tcp" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole_accessible.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 3389
  to_port                  = 3389
}

# Allow ingress from Guacamole instances via RDP (UDP)
resource "aws_security_group_rule" "ingress_from_guacamole_via_rdp_over_udp" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole_accessible.id
  type                     = "ingress"
  protocol                 = "udp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 3389
  to_port                  = 3389
}

# Allow ingress from Guacamole instances via VNC
resource "aws_security_group_rule" "ingress_from_guacamole_via_vnc" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole_accessible.id
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole.id
  from_port                = 5901
  to_port                  = 5901
}
