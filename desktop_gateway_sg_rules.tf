# Allow ingress from COOL Shared Services via ssh
# For: DevOps ssh access to Guacamole instance
resource "aws_security_group_rule" "desktop_gw_ingress_from_cool_via_ssh" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [local.cool_shared_services_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port = 22
  to_port   = 22
}

# # Allow egress via ssh to the assessment operating instance(s)
# # For: DevOps ssh access to assessment operating instance(s)
# resource "aws_security_group_rule" "desktop_gw_egress_to_ops_via_ssh" {
#   provider = aws.provisionassessment
#
#   security_group_id = aws_security_group.desktop_gateway.id
#   type              = "egress"
#   protocol          = "tcp"
#   cidr_blocks       = ["${aws_instance.TBD.private_ip}/32"]
#   from_port         = 22
#   to_port           = 22
# }

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

# Allow ingress from COOL Shared Services via port 8443 (nginx/guacamole web)
# For: Assessment team access to Guacamole web client
resource "aws_security_group_rule" "desktop_gw_ingress_from_trusted_via_port_8443" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [local.cool_shared_services_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port = 8443
  to_port   = 8443
}

# # Allow egress via VNC to the assessment operating instance(s)
# # For: Assessment team VNC access to assessment operating instance(s)
# resource "aws_security_group_rule" "desktop_gw_egress_to_ops_via_vnc" {
#   provider = aws.provisionassessment
#
#   security_group_id = aws_security_group.pca_desktop_gateway.id
#   type              = "egress"
#   protocol          = "tcp"
#   cidr_blocks       = ["${aws_instance.TBD.private_ip}/32"]
#   from_port         = 5901
#   to_port           = 5901
# }

# Allow ingress from anywhere via ephemeral ports below 8443 (1024-8442)
# We do not want to allow everyone to hit Guacamole on port 8443
# For: Guacamole fetches its SSL certificate via boto3 (which uses HTTPS)
resource "aws_security_group_rule" "desktop_gw_ingress_from_anywhere_via_ports_1024_thru_8442" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 1024
  to_port           = 8442
}

# Allow ingress from anywhere via ephemeral ports above 8443 (8444-65535)
# We do not want to allow everyone to hit Guacamole on port 8443
# For: Guacamole fetches its SSL certificate via boto3 (which uses HTTPS)
resource "aws_security_group_rule" "desktop_gw_ingress_from_anywhere_via_ports_8444_thru_65535" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8444
  to_port           = 65535
}
