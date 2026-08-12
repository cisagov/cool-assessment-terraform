# ------------------------------------------------------------------------------
# Retrieve the caller identity for the current assessment in order to
# get the associated Account ID.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "assessment" {
  provider = aws.provisionassessment
}

# ------------------------------------------------------------------------------
# Retrieve the effective Account ID, User ID, and ARN in which Terraform is
# authorized.  This is used to calculate the session names for assumed roles.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Retrieve the information for all accouts in the organization.  This is used
# to lookup the Users account ID for use in the assume role policy.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "cool" {
  provider = aws.organizationsreadonly
}

# ------------------------------------------------------------------------------
# Retrieve the default tags for the assessment provider.  These are
# used to create volume tags for EC2 instances, since volume_tags does
# not yet inherit the default tags from the provider.  See
# hashicorp/terraform-provider-aws#19188 for more details.
# ------------------------------------------------------------------------------
data "aws_default_tags" "assessment" {
  provider = aws.provisionassessment
}

# ------------------------------------------------------------------------------
# Retrieve SSM Parameter Store parameters.
# Note: These values are stored in plaintext in the state, but it should be fine
# because we are using a remote state that we have configured to be encrypted.
# ------------------------------------------------------------------------------
data "aws_ssm_parameter" "artifact_export_access_key_id_1" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_access_key_id_1
}

data "aws_ssm_parameter" "artifact_export_access_key_id_2" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_access_key_id_2
}

data "aws_ssm_parameter" "artifact_export_bucket_name_1" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_bucket_name_1
}

data "aws_ssm_parameter" "artifact_export_bucket_name_2" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_bucket_name_2
}

data "aws_ssm_parameter" "artifact_export_region_1" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_region_1
}

data "aws_ssm_parameter" "artifact_export_region_2" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_region_2
}

data "aws_ssm_parameter" "artifact_export_secret_access_key_1" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_secret_access_key_1
}

data "aws_ssm_parameter" "artifact_export_secret_access_key_2" {
  count    = var.assessment_artifact_export_enabled ? 1 : 0
  provider = aws.parameterstorereadonly

  name = var.ssm_key_artifact_export_secret_access_key_2
}

data "aws_ssm_parameter" "samba_username" {
  provider = aws.parameterstorereadonly

  name = var.ssm_key_samba_username
}

# This should be removed once Windows AMIs are being built with the correct
# public SSH key(s) preloaded. Please see #218 for more information.
data "aws_ssm_parameter" "vnc_public_ssh_key" {
  provider = aws.parameterstorereadonly

  name = var.ssm_key_vnc_ssh_public_key
}

data "aws_ssm_parameter" "vnc_username" {
  provider = aws.parameterstorereadonly

  name = var.ssm_key_vnc_username
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # The account ID for this assessment
  assessment_account_id = data.aws_caller_identity.assessment.account_id

  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  cool_dns_private_zone = data.terraform_remote_state.sharedservices_networking.outputs.private_zone

  cool_shared_services_cidr_block = data.terraform_remote_state.sharedservices_networking.outputs.vpc.cidr_block

  docker_ebs_device_name    = "/dev/xvdb"
  docker_volume_mount_point = "/docker_data"

  guacamole_fqdn = format("guac.%s.%s", local.assessment_account_name, var.cool_domain)

  # Look up assessment account name from AWS organizations provider
  assessment_account_name = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.name
    if account.id == local.assessment_account_id
  ][0]

  # Find the "Images" account ID by name.
  images_account_id = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.id if account.name == "Images"
  ][0]

  # The name and description of the role that allows read-only
  # access to the Nessus-related SSM Parameter Store parameters in the
  # Images account.
  nessus_parameterstorereadonly_role_description = format("Allows read-only access to Nessus-related SSM Parameter Store parameters required for the %s assessment.", var.assessment_account_name)

  nessus_parameterstorereadonly_role_name = format("ParameterStoreReadOnly-%s-Nessus", terraform.workspace)

  # Create a list of all operations instance ARNs.  Don't forget to update this
  # list when adding new instance types.
  operations_instances_arns = concat(
    aws_instance.debiandesktop.*.arn,
    aws_instance.egressassess.*.arn,
    aws_instance.gophish.*.arn,
    aws_instance.kali.*.arn,
    aws_instance.nessus.*.arn,
    aws_instance.pentestportal.*.arn,
    aws_instance.teamserver.*.arn,
    aws_instance.windows.*.arn,
  )

  # These ports must never be publicly reachable at the operations subnet
  # ACL, regardless of the ranges produced by inbound_ports_allowed.
  # These deny rules are numbered below the "allowed ports" rule
  # (150/151) so they take precedence (first-match wins in a NACL).
  operations_denied_public_ports = {
    rdp        = { port = 3389, rule_number = 145 }
    teamserver = { port = 50050, rule_number = 146 }
  }

  # Return a map containing the union of all ports to be opened for
  # instance types that will actually be instantiated in the
  # operations subnet.
  union_of_inbound_ports_allowed = {
    for d in distinct(flatten([for k, v in var.inbound_ports_allowed : v if var.operations_instance_counts[k] > 0])) :
    format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => d
  }

  # List of protocols that appear in union_of_inbound_ports_allowed
  union_of_inbound_ports_allowed_protocols = sort(distinct([for k, v in local.union_of_inbound_ports_allowed : v.protocol]))

  # Map of inbound ports allowed by protocol
  union_of_inbound_ports_allowed_by_protocol = {
    for p in local.union_of_inbound_ports_allowed_protocols :
    p => {
      for k, v in local.union_of_inbound_ports_allowed :
      k => v if v.protocol == p
    }
  }

  # Map of minimum inbound ports allowed by protocol
  min_inbound_ports_allowed_by_protocol = {
    for p in local.union_of_inbound_ports_allowed_protocols :
    p => min([
      for k, v in local.union_of_inbound_ports_allowed_by_protocol[p] : v.from_port
    ]...)
  }

  # Map of maximum inbound ports allowed by protocol
  max_inbound_ports_allowed_by_protocol = {
    for p in local.union_of_inbound_ports_allowed_protocols :
    p => max([
      for k, v in local.union_of_inbound_ports_allowed_by_protocol[p] : v.to_port
    ]...)
  }

  # Map of allowed port ranges that can be used to create ACL rules.
  inbound_ports_allowed_for_acl = {
    for index, p in local.union_of_inbound_ports_allowed_protocols :
    format("%s_%d_%d", p, local.min_inbound_ports_allowed_by_protocol[p], local.max_inbound_ports_allowed_by_protocol[p]) => {
      index     = index,
      from_port = local.min_inbound_ports_allowed_by_protocol[p],
      protocol  = p,
      to_port   = local.max_inbound_ports_allowed_by_protocol[p],
    }
  }

  # If var.private_domain is provided, use it.  Otherwise, default to
  # local.assessment_account_name
  private_domain = var.private_domain != "" ? var.private_domain : local.assessment_account_name

  # Helpful lists for defining ACL and security group rules

  # The ports used to communicate with IPA servers.  The "index" value
  # is used as a counter in certain ACL rules
  # (aws_network_acl_rule.private_egress_to_cool_via_ipa_ports in
  # private_acl_rules.tf).
  ipa_ports = {
    http = {
      protocol = "tcp",
      port     = 80,
      index    = 1,
    },
    kinit_tcp = {
      protocol = "tcp",
      port     = 88,
      index    = 2,
    },
    kinit_udp = {
      protocol = "udp",
      port     = 88,
      index    = 3,
    },
    https = {
      protocol = "tcp",
      port     = 443,
      index    = 4,
    },
    kpasswd_tcp = {
      protocol = "tcp",
      port     = 464,
      index    = 5,
    },
    kpasswd_udp = {
      protocol = "udp",
      port     = 464,
      index    = 6,
    },
    ldap = {
      protocol = "tcp",
      port     = 389,
      index    = 7,
    },
    ldaps = {
      protocol = "tcp",
      port     = 636,
      index    = 8,
    }
  }

  ingress_and_egress = [
    "ingress",
    "egress",
  ]
  tcp_and_udp = [
    "tcp",
    "udp",
  ]

  # Ports to be accessed via the VPN in assessment environments
  # (e.g. for Guacamole, Mattermost, etc.)
  assessment_env_service_ports = {
    http = {
      port     = 80
      protocol = "tcp"
    },
    https = {
      port     = 443
      protocol = "tcp"
    },
    mm_unknown0 = {
      port     = 3478
      protocol = "udp"
    },
    mm_unknown1 = {
      port     = 5349
      protocol = "tcp"
    },
    mm_web = {
      port     = 8065
      protocol = "tcp"
    },
    mm_unknown2 = {
      port     = 10000
      protocol = "udp"
    },
  }

  # The ID of the Transit Gateway in the Shared Services account.
  transit_gateway_id = data.terraform_remote_state.sharedservices_networking.outputs.transit_gateway.id
  # The ID of the default route table associated with the Transit
  # Gateway in the Shared Services account.
  transit_gateway_default_route_table_id = data.terraform_remote_state.sharedservices_networking.outputs.transit_gateway.association_default_route_table_id
  # The ID of the route table to be associated with the Transit
  # Gateway attachment for this account.
  transit_gateway_route_table_id = data.terraform_remote_state.sharedservices_networking.outputs.transit_gateway_attachment_route_tables[local.assessment_account_id].id

  # Find the Users account by name.
  users_account_id = [
    for x in data.aws_organizations_organization.cool.non_master_accounts :
    x.id if x.name == "Users"
  ][0]

  # The name and description of the role and policy that allows read-only
  # access to the VNC-related and RDP-related SSM Parameter Store
  # parameters in the Images account.
  guacamole_parameterstorereadonly_role_description = format("Allows read-only access to VNC-related and RDP-related SSM Parameter Store parameters required for the %s assessment.", var.assessment_account_name)

  guacamole_parameterstorereadonly_role_name = format("ParameterStoreReadOnly-%s-VNC-RDP", terraform.workspace)

  # Calculate the VPN server CIDR block using the
  # sharedservices_networking remote state
  #
  # Swiped from:
  # https://github.com/cisagov/cool-sharedservices-openvpn/blob/c3ad7d74a78be903b137a1e6a095d45a0bfe7ea6/openvpn.tf#L6-L19
  #
  # OpenVPN currently only uses a single public subnet, so grab the
  # CIDR of the one with the smallest third octet.
  #
  # It's tempting to just use keys()[0] here, but the keys are sorted
  # lexicographically.  That means that "10.1.10.0/24" would come
  # before "10.1.9.0/24".
  cool_public_subnet_cidrs = keys(data.terraform_remote_state.sharedservices_networking.outputs.public_subnets)

  cool_public_subnet_first_octet  = split(".", local.cool_public_subnet_cidrs[0])[0]
  cool_public_subnet_second_octet = split(".", local.cool_public_subnet_cidrs[0])[1]
  cool_public_subnet_third_octets = [for cidr in local.cool_public_subnet_cidrs : split(".", cidr)[2]]

  # This flatten([]) shouldn't be necessary, but it is.  I think this
  # is related to hashicorp/terraform#22404.
  lowest_third_octet = min(flatten([local.cool_public_subnet_third_octets])...)

  vpn_server_cidr_block = format("%d.%d.%d.0/24", local.cool_public_subnet_first_octet, local.cool_public_subnet_second_octet, local.lowest_third_octet)
}
