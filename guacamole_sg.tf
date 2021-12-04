# Security group for Guacamole instances
resource "aws_security_group" "guacamole" {
  provider = aws.provisionassessment

  vpc_id = aws_vpc.assessment.id

  tags = {
    Name = "Guacamole (desktop gateway)"
  }
}

# Allow egress via SSH to instances that wish to be accessible via
# Guacamole
resource "aws_security_group_rule" "guacamole_egress_to_hosts_via_ssh" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole_accessible.id
  from_port                = 22
  to_port                  = 22
}

# Allow egress via VNC to instances that wish to be accessible via
# Guacamole
resource "aws_security_group_rule" "guacamole_egress_to_hosts_via_vnc" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.guacamole_accessible.id
  from_port                = 5900
  to_port                  = 5901
}

# Allow egress via HTTPS to any EC2 interface endpoint
#
# For: The Guacamole instance has to be able to query EC2 for instance
# information in order to keep the Guacamole connection database in
# sync as instances appear and disappear.
resource "aws_security_group_rule" "guacamole_egress_to_ec2_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via HTTPS to any STS interface endpoint
#
# For: Guacamole assumes a role via STS.  This role allows Guacamole
# to then fetch its SSL certificate from S3.
resource "aws_security_group_rule" "guacamole_egress_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.guacamole.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sts.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via HTTPS to the S3 gateway endpoint
#
# For: Guacamole requires access to S3 in order to download its
# certificate.
resource "aws_security_group_rule" "guacamole_egress_to_s3_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.guacamole.id
  type              = "egress"
  protocol          = "tcp"
  prefix_list_ids   = [aws_vpc_endpoint.s3.prefix_list_id]
  from_port         = 443
  to_port           = 443
}

# Allow ingress from COOL Shared Services VPN server CIDR block
# via HTTPS
#
# For: Assessment team access to Guacamole web client
resource "aws_security_group_rule" "guacamole_ingress_from_trusted_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.guacamole.id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [local.vpn_server_cidr_block]
  # ipv6_cidr_blocks  = TBD
  from_port = 443
  to_port   = 443
}

# Allow egress to COOL Shared Services via IPA-related ports
#
# For: Guacamole instance communication with FreeIPA
resource "aws_security_group_rule" "guacamole_egress_to_cool_via_ipa_ports" {
  provider = aws.provisionassessment
  for_each = local.ipa_ports

  security_group_id = aws_security_group.guacamole.id
  type              = "egress"
  protocol          = each.value.protocol
  cidr_blocks       = [local.cool_shared_services_cidr_block]
  from_port         = each.value.port
  to_port           = each.value.port
}
