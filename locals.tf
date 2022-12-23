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
data "aws_ssm_parameter" "samba_username" {
  provider = aws.parameterstorereadonly

  name = var.ssm_key_samba_username
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

  guacamole_fqdn = format("guac.%s.%s", local.assessment_account_name_base, var.cool_domain)

  # Look up assessment account name from AWS organizations provider
  assessment_account_name = [
    for account in data.aws_organizations_organization.cool.accounts :
    account.name
    if account.id == local.assessment_account_id
  ][0]

  # Determine assessment account type based on account name.
  #
  # The account name format is "ACCOUNT_NAME (ACCOUNT_TYPE)" - for
  # example, "env0 (Production)".
  assessment_account_type = length(regexall("\\(([^()]*)\\)", local.assessment_account_name)) == 1 ? regex("\\(([^()]*)\\)", local.assessment_account_name)[0] : "Unknown"
  workspace_type          = lower(local.assessment_account_type)

  # The Terraform workspace name for this assessment
  assessment_workspace_name = replace(replace(lower(var.assessment_account_name), "/[()]/", ""), " ", "-")

  # Note that we are assuming that the assessment account name does
  # not contain a "(" character.
  assessment_account_name_base = trimspace(split("(", var.assessment_account_name)[0])

  # Determine the ID of the corresponding Images account
  images_account_id = [
    for account in data.aws_organizations_organization.cool.accounts :
    account.id
    if account.name == "Images (${local.assessment_account_type})"
  ][0]

  # The name and description of the role that allows read-only
  # access to the Nessus-related SSM Parameter Store parameters in the
  # Images account.
  nessus_parameterstorereadonly_role_description = format("Allows read-only access to Nessus-related SSM Parameter Store parameters required for the %s assessment.", var.assessment_account_name)

  nessus_parameterstorereadonly_role_name = format("ParameterStoreReadOnly-%s-Nessus", local.assessment_workspace_name)

  # Return a map containing the union of all ports to be opened for
  # instance types that will actually be instantiated in the
  # operations subnet.  We merge the index into the map so that we can
  # number the corresponding ACL rules consecutively.
  union_of_inbound_ports_allowed = { for index, d in distinct(flatten([for k, v in var.inbound_ports_allowed : v if var.operations_instance_counts[k] > 0])) : format("%s_%d_%d", d.protocol, d.from_port, d.to_port) => merge(d, { "index" = index }) }

  # If var.private_domain is provided, use it.  Otherwise, default to
  # local.assessment_account_name_base
  private_domain = var.private_domain != "" ? var.private_domain : local.assessment_account_name_base

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

  # Find the new Users account by name and email.
  users_account_id = [
    for x in data.aws_organizations_organization.cool.accounts :
    x.id if x.name == "Users" && length(regexall("2020", x.email)) > 0
  ][0]

  # The name and description of the role and policy that allows read-only
  # access to the VNC-related and RDP-related SSM Parameter Store
  # parameters in the Images account.
  guacamole_parameterstorereadonly_role_description = format("Allows read-only access to VNC-related and RDP-related SSM Parameter Store parameters required for the %s assessment.", var.assessment_account_name)

  guacamole_parameterstorereadonly_role_name = format("ParameterStoreReadOnly-%s-VNC-RDP", local.assessment_workspace_name)

  # Calculate the VPN server CIDR block using the
  # sharedservices_networking remote state
  #
  # Swiped from:
  # https://github.com/cisagov/cool-sharedservices-openvpn/blob/improvement/update-for-cool-multiaccount/openvpn.tf#L12-L27
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
