#####
# Ingress rules
#####

#####
# Rules associated with the services hosted in the private subnets to
# which the assessors are granted direct access (i.e. not via
# Guacamole).  These services include Guacamole and Mattermost.
#####
# Allow ingress from COOL Shared Services VPN server CIDR block via
# ports used by services hosted in the private subnet.
#
# For: Assessment team access to services hosted in the private subnet
# (i.e. Guacamole, Mattermost, etc.)
resource "aws_network_acl_rule" "private_ingress_from_cool_vpn_services" {
  provider = aws.provisionassessment
  # This insanity returns a map with
  # length(local.assessment_env_service_ports) *
  # length(var.private_subnet_cidr_blocks) distinct keys, where each
  # value is a map that is simply one of the entries from
  # local.assessment_env_service_ports modified to include:
  # * One of the entries in var.private_subnet_cidr_blocks under the
  # key "private_subnet_cidr_block"
  # * An index into the setproduct result under the key "index".  This
  # is simply used to provide an offset for the rule number.
  for_each = {
    for index, pair in setproduct(keys(local.assessment_env_service_ports), var.private_subnet_cidr_blocks) :
    format("%s_%s", pair[0], pair[1]) => merge(local.assessment_env_service_ports[pair[0]], { "private_subnet_cidr_block" = pair[1], "index" = index })
  }

  network_acl_id = aws_network_acl.private[each.value.private_subnet_cidr_block].id
  egress         = false
  protocol       = each.value.protocol
  rule_number    = 100 + each.value.index
  rule_action    = "allow"
  cidr_block     = local.vpn_server_cidr_block
  from_port      = each.value.port
  to_port        = each.value.port
}
# Allow ingress from operations subnet via port 8065.
#
# For: Operations subnet access to Mattermost web service hosted in
# the private subnet.
resource "aws_network_acl_rule" "private_ingress_from_operations_mattermost_web" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 120
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 8065
  to_port        = 8065
}
# Allow ingress to first private subnet (where Transit Gateway attachment
# resides) from private subnets via UDP ephemeral ports.
#
# For: Advanced Operations VPN endpoint communications that must flow through
# the Transit Gateway.  For reference, see:
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-nacls.html
resource "aws_network_acl_rule" "private_ingress_to_tg_attachment_via_udp_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[var.private_subnet_cidr_blocks[0]].id
  egress         = false
  protocol       = "udp"
  rule_number    = 125 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}
# Disallow ingress from anywhere else via ports used by services
# hosted in the private subnet.
locals {
  assessment_env_service_ports_gte_1024 = {
    for key, value in local.assessment_env_service_ports :
    key => value
    if value.port >= 1024
  }
}
resource "aws_network_acl_rule" "private_ingress_from_anywhere_else_services" {
  provider = aws.provisionassessment
  # This insanity returns a map with
  # length(local.assessment_env_service_ports_gte_1024) *
  # length(var.private_subnet_cidr_blocks) distinct keys, where each
  # value is a map that is simply one of the entries from
  # local.assessment_env_service_ports_gte_1024 modified to include:
  # * One of the entries in var.private_subnet_cidr_blocks under the
  # key "private_subnet_cidr_block"
  # * An index into the setproduct result under the key "index".  This
  # is simply used to provide an offset for the rule number.
  for_each = {
    for index, pair in setproduct(keys(local.assessment_env_service_ports_gte_1024), var.private_subnet_cidr_blocks) :
    format("%s_%s", pair[0], pair[1]) => merge(local.assessment_env_service_ports_gte_1024[pair[0]], { "private_subnet_cidr_block" = pair[1], "index" = index })
  }

  network_acl_id = aws_network_acl.private[each.value.private_subnet_cidr_block].id
  egress         = false
  protocol       = each.value.protocol
  rule_number    = 130 + each.value.index
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = each.value.port
  to_port        = each.value.port
}

#####
# Rules associated with file sharing (EFS and SMB)
#####
# Allow ingress from operations subnet via port 2049.
#
# For: Operations subnet access to EFS mountpoints.
resource "aws_network_acl_rule" "private_ingress_from_operations_efs" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 150
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 2049
  to_port        = 2049
}
# Allow ingress from operations subnet via port 445.
#
# For: Operations subnet access to SMB server(s).
#
# There is no need for an explicit deny for everyone else since SMB
# does not run on a port in the ephemeral range.
resource "aws_network_acl_rule" "private_ingress_from_operations_smb" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 155
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 445
  to_port        = 445
}
# Disallow ingress from anywhere else via port 2049.
resource "aws_network_acl_rule" "private_ingress_from_anywhere_else_efs" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 160
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 2049
  to_port        = 2049
}

# Allow ingress from anywhere via ephemeral ports that are not already
# explicitly denied.
#
# For: Guacamole fetches its SSL certificate via boto3 (which uses
# HTTPS).  This also allows the return traffic from any requests sent
# out via the NAT gateway in the operations subnet.
resource "aws_network_acl_rule" "private_ingress_from_anywhere_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 170 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow ingress from private subnet to private subnet via IPA-related
# ports.  Note that none of these ports are in the ephemeral port
# range.
#
# For: Guacamole instance communication with FreeIPA
#
# Full disclosure: We are not totally clear on why this access is
# needed, but without it, traffic is unable to go from the Guacamole
# instance to the Transit Gateway attachment (both reside in the same
# private subnet).
resource "aws_network_acl_rule" "private_ingress_to_tg_attachment_via_ipa_ports" {
  provider = aws.provisionassessment
  # This insanity returns a map with length(local.ipa_ports) *
  # length(var.private_subnet_cidr_blocks) distinct keys, where each
  # value is a map that is simply one of the entries from
  # local.assessment_env_service_ports modified to include:
  # * One of the entries in var.private_subnet_cidr_blocks under the
  # key "private_subnet_cidr_block"
  # * An index into the setproduct result under the key "index".  This
  # is simply used to provide an offset for the rule number.
  for_each = {
    for index, pair in setproduct(keys(local.ipa_ports), var.private_subnet_cidr_blocks) :
    format("%s_%s", pair[0], pair[1]) => merge(local.ipa_ports[pair[0]], { "private_subnet_cidr_block" = pair[1], "index" = index })
  }

  network_acl_id = aws_network_acl.private[var.private_subnet_cidr_blocks[0]].id
  egress         = false
  protocol       = each.value.protocol
  rule_number    = 180 + each.value.index
  rule_action    = "allow"
  cidr_block     = each.value.private_subnet_cidr_block
  from_port      = each.value.port
  to_port        = each.value.port
}

# Allow ingress from the operations subnet via https
#
# For: Operations subnet access to VPC endpoints
resource "aws_network_acl_rule" "private_ingress_from_operations_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "tcp"
  rule_number    = 200 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 443
  to_port        = 443
}

# Allow ingress from 172.16.0.0/12 via all ports and protocols
#
# For: Advanced Operations communication with local virtual machines
resource "aws_network_acl_rule" "private_ingress_from_local_vm_ips_via_all_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = false
  protocol       = "all"
  rule_number    = 210 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "172.16.0.0/12"
}

#####
# Egress rules
#####

# Allow egress to anywhere via ssh
#
# For: Terraformer instances need to be able to configure operations
# instances and redirectors via Ansible.
resource "aws_network_acl_rule" "private_egress_to_anywhere_via_ssh" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 300 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# Allow egress to the operations subnet via port 5986 (Windows Remote
# Management).
#
# For: Terraformer instances need to be able to configure
# Windows-based operations instances via Ansible.
resource "aws_network_acl_rule" "private_egress_to_operations_via_winrm" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 310 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 5986
  to_port        = 5986
}

# Allow egress to anywhere via HTTP
#
# For: Terraformer instances need to be able to install packages.
resource "aws_network_acl_rule" "private_egress_to_anywhere_via_http" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 320 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow egress to anywhere via HTTPS
#
# For: Guacamole assumes a role via STS.  This role allows Guacamole
# to then fetch its SSL certificate from S3.  The Terraformer
# instances also need to perform terraform init.
#
# Note that, even though the S3 traffic is routed to the S3 VPC
# gateway endpoint via the router, it still leaves the subnet as
# traffic destined for a public IP of the S3 AWS API.
resource "aws_network_acl_rule" "private_egress_to_anywhere_via_https" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 330 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow egress to COOL Shared Services via TCP ephemeral ports
#
# For: Assessment team access to guacamole web client
resource "aws_network_acl_rule" "private_egress_to_cool_via_tcp_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 340 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = local.cool_shared_services_cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow egress to COOL Shared Services via UDP ephemeral ports
#
# For: Assessment team access to Advanced Operations VPN endpoints
resource "aws_network_acl_rule" "private_egress_to_cool_via_udp_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "udp"
  rule_number    = 350 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = local.cool_shared_services_cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow egress to operations subnet via ephemeral ports, for EFS
# access.  (EFS is just NFS under the hood.)
resource "aws_network_acl_rule" "private_egress_to_operations_via_ephemeral_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 360 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 1024
  to_port        = 65535
}

# Allow egress to operations subnet via ssh
#
# For: DevOps ssh access from private subnet to operations subnet
resource "aws_network_acl_rule" "private_egress_to_operations_via_ssh" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 370 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 22
  to_port        = 22
}

# Allow egress to operations subnet via VNC
# For: Assessment team VNC access from private subnet to operations subnet
resource "aws_network_acl_rule" "private_egress_to_operations_via_vnc" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "tcp"
  rule_number    = 380 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = aws_subnet.operations.cidr_block
  from_port      = 5901
  to_port        = 5901
}

# Allow egress to COOL Shared Services via IPA-related ports
#
# For: Guacamole instance communication with FreeIPA
#
# Note that these rules only apply to the private subnet with
# Guacamole.
resource "aws_network_acl_rule" "private_egress_to_cool_via_ipa_ports" {
  provider = aws.provisionassessment
  for_each = local.ipa_ports

  network_acl_id = aws_network_acl.private[var.private_subnet_cidr_blocks[0]].id
  egress         = true
  protocol       = each.value.protocol
  rule_number    = 400 + each.value.index
  rule_action    = "allow"
  cidr_block     = local.cool_shared_services_cidr_block
  from_port      = each.value.port
  to_port        = each.value.port
}

# Allow egress to 172.16.0.0/12 via all ports and protocols
#
# For: Advanced Operations communication with local virtual machines
resource "aws_network_acl_rule" "private_egress_to_local_vm_ips_via_all_ports" {
  provider = aws.provisionassessment
  for_each = toset(var.private_subnet_cidr_blocks)

  network_acl_id = aws_network_acl.private[each.value].id
  egress         = true
  protocol       = "all"
  rule_number    = 410 + index(var.private_subnet_cidr_blocks, each.value)
  rule_action    = "allow"
  cidr_block     = "172.16.0.0/12"
}
