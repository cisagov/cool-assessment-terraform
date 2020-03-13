# Allow ingress from COOL Shared Services VPN server CIDR block via ssh
# For: DevOps ssh access to Guacamole instance
resource "aws_security_group_rule" "desktop_gw_ingress_from_cool_via_ssh" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [local.vpn_server_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port = 22
  to_port   = 22
}

# Allow egress via ssh to the Operations subnet
# For: DevOps ssh access to assessment operating instances
resource "aws_security_group_rule" "desktop_gw_egress_to_ops_via_ssh" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.operations.cidr_block]
  from_port         = 22
  to_port           = 22
}

# Allow egress via https to anywhere
# For: Guacamole fetches its SSL certificate via boto3 (which uses HTTPS)
resource "aws_security_group_rule" "desktop_gw_egress_to_anywhere_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

# Allow ingress from COOL Shared Services VPN server CIDR block
# via port 443 (nginx/guacamole web)
# For: Assessment team access to Guacamole web client
resource "aws_security_group_rule" "desktop_gw_ingress_from_trusted_via_port_443" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [local.vpn_server_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port = 443
  to_port   = 443
}

# Allow egress via VNC to the Operations subnet
# For: Assessment team VNC (via Guacamole) access to
# assessment operating instances
resource "aws_security_group_rule" "desktop_gw_egress_to_ops_via_vnc" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.operations.cidr_block]
  from_port         = 5901
  to_port           = 5901
}

# Allow ingress from anywhere via ephemeral ports
# For: Guacamole fetches its SSL certificate via boto3 (which uses HTTPS)
resource "aws_security_group_rule" "desktop_gw_ingress_from_anywhere_via_ephemeral_ports" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 1024
  to_port           = 65535
}
