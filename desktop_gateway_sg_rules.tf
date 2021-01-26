# Allow egress via ssh to the Operations subnet
# For: Guacamole scp access to assessment operating instances
resource "aws_security_group_rule" "desktop_gw_egress_to_ops_via_ssh" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.operations.cidr_block]
  from_port         = 22
  to_port           = 22
}

# Allow egress via https
#
# For: Guacamole access to DockerHub via the NAT gateway
resource "aws_security_group_rule" "desktop_gw_egress_anywhere_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

# Allow egress via https to any STS interface endpoint
#
# For: Guacamole assumes a role via STS.  This role allows Guacamole
# to then fetch its SSL certificate from S3.
resource "aws_security_group_rule" "desktop_gw_egress_to_sts_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.desktop_gateway.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sts.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via https to any SSM interface endpoints
#
# For: Guacamole requires access to SSM for ssh access via the AWS
# control plane.
resource "aws_security_group_rule" "desktop_gw_egress_to_ssm_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.desktop_gateway.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ssm.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via https to any Cloudwatch interface endpoints
#
# For: Guacamole requires access to CloudWatch for CloudWatch log
# forwarding via the CloudWatch agent.
resource "aws_security_group_rule" "desktop_gw_egress_to_cloudwatch_via_https" {
  provider = aws.provisionassessment

  security_group_id        = aws_security_group.desktop_gateway.id
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cloudwatch.id
  from_port                = 443
  to_port                  = 443
}

# Allow egress via https to the S3 gateway endpoint
#
# For: Guacamole requires access to S3 in order to download its
# certificate.
resource "aws_security_group_rule" "desktop_gw_egress_to_s3_via_https" {
  provider = aws.provisionassessment

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = "tcp"
  prefix_list_ids   = [aws_vpc_endpoint.s3.prefix_list_id]
  from_port         = 443
  to_port           = 443
}

# Allow ingress from COOL Shared Services VPN server CIDR block
# via port 443 (nginx/Guacamole web)
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

# Allow egress to COOL Shared Services via IPA-related ports
# For: Guacamole instance communication with FreeIPA
resource "aws_security_group_rule" "desktop_gw_egress_to_cool_via_ipa_ports" {
  provider = aws.provisionassessment
  for_each = local.ipa_ports

  security_group_id = aws_security_group.desktop_gateway.id
  type              = "egress"
  protocol          = each.value.proto
  cidr_blocks       = [local.cool_shared_services_cidr_block]
  from_port         = each.value.port
  to_port           = each.value.port
}
