# Security group for the instances accessible by Guacamole
resource "aws_security_group" "guacamole_accessible" {
  provider = aws.provisionassessment

  tags = {
    Name = "Guacamole accessible"
  }
  vpc_id = aws_vpc.assessment.id
}

# Allow ingress from Guacamole instances via SSH
resource "aws_security_group_rule" "ingress_from_guacamole_via_ssh" {
  provider = aws.provisionassessment

  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.guacamole_accessible.id
  source_security_group_id = aws_security_group.guacamole.id
  to_port                  = 22
  type                     = "ingress"
}

# Allow ingress from Guacamole instances via VNC
resource "aws_security_group_rule" "ingress_from_guacamole_via_vnc" {
  provider = aws.provisionassessment

  from_port                = 5901
  protocol                 = "tcp"
  security_group_id        = aws_security_group.guacamole_accessible.id
  source_security_group_id = aws_security_group.guacamole.id
  to_port                  = 5901
  type                     = "ingress"
}
