# cloud-init commands for configuring teamserver instances

locals {
  # These values are used twice below, so we may as well define them
  # in one place.
  full_chain_pem = "/tmp/fullchain.pem"
  priv_key_pem   = "/tmp/privkey.pem"
}

data "cloudinit_config" "teamserver_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "teamserver", 0)

  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to
  # name the mime-parts of the user-data.  They do not affect the
  # final name for the templates. For any x-shellscript parts, the
  # filenames will also be used as a filename in the scripts
  # directory.

  # Set the local hostname.
  #
  # We need to go ahead and set the local hostname to the correct
  # value that will eventually be obtained from DHCP, since we make
  # liberal use of the "{local_hostname}" placeholder in our AWS
  # CloudWatch Agent configuration.
  part {
    content = templatefile(
      "${path.module}/cloud-init/set-hostname.tpl.yml", {
        # Note that the hostname here is identical to what is set in
        # the corresponding DNS A record.
        fqdn     = "teamserver${count.index}.${aws_route53_zone.assessment_private.name}"
        hostname = "teamserver${count.index}"
    })
    content_type = "text/cloud-config"
    filename     = "set-hostname.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Fix the DHCP options in the Canonical Netplan configuration
  # created by cloud-init.
  #
  # The issue is that Netplan uses a default of false for
  # dhcp4-overrides.use-domains, and cloud-init does not explicitly
  # set this key or provide any way to do so.
  #
  # See these issues for more details:
  # - cisagov/skeleton-packer#300
  # - canonical/cloud-init#4764
  part {
    content = templatefile(
      "${path.module}/cloud-init/fix-dhcp.tpl.py", {
        netplan_config = "/etc/netplan/50-cloud-init.yaml"
    })
    content_type = "text/x-shellscript"
    filename     = "fix-dhcp.py"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Now that the DHCP options in the Canonical Netplan configuration
  # created by cloud-init have been fixed, reapply the Netplan
  # configuration.
  #
  # The issue is that Netplan uses a default of false for
  # dhcp4-overrides.use-domains, and cloud-init does not explicitly
  # set this key or provide any way to do so.
  #
  # See these issues for more details:
  # - cisagov/skeleton-packer#300
  # - canonical/cloud-init#4764
  part {
    content      = file("${path.module}/cloud-init/fix-dhcp.yml")
    content_type = "text/cloud-config"
    filename     = "fix-dhcp.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Create an fstab entry for the EFS share
  part {
    content = templatefile(
      "${path.module}/cloud-init/efs-mount.tpl.yml", {
        # Use the access point that corresponds with the EFS mount target used
        efs_ap_id = aws_efs_access_point.access_point[var.private_subnet_cidr_blocks[0]].id
        # Just mount the EFS mount target in the first private subnet
        efs_id      = aws_efs_mount_target.target[var.private_subnet_cidr_blocks[0]].file_system_id
        group       = var.efs_users_group_name
        mount_point = "/share"
        owner       = data.aws_ssm_parameter.vnc_username.value
    })
    content_type = "text/cloud-config"
    filename     = "efs_mount.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # This shell script loops until the EFS share is mounted.  We do
  # make the instance depend on the EFS share in the Terraform code,
  # but it is still possible for an instance to boot up without
  # mounting the share.  See this issue comment for more details:
  # https://github.com/cisagov/cool-assessment-terraform/issues/85#issuecomment-754052796
  part {
    content = templatefile(
      "${path.module}/cloud-init/mount-efs-share.tpl.sh", {
        mount_point = "/share"
    })
    content_type = "text/x-shellscript"
    filename     = "mount-efs-share.sh"
  }

  # Install certificates.  Note that this script and the next one must
  # take place in a certain order, so we prepend numbers to the script
  # names to force that to that happen.
  #
  # Here is where the user scripts are called by cloud-init:
  # https://github.com/canonical/cloud-init/blob/master/cloudinit/config/cc_scripts_user.py#L45
  #
  # And here is where you can see how cloud-init sorts the scripts:
  # https://github.com/canonical/cloud-init/blob/master/cloudinit/subp.py#L373
  part {
    content = templatefile(
      "${path.module}/cloud-init/install-certificates.tpl.py", {
        aws_region       = var.aws_region
        cert_bucket_name = var.cert_bucket_name
        # We use the element() function below instead of the built-in list
        # index syntax because we want the "wrap-around" behavior provided
        # by element().  This means that the number of items in
        # var.email_sending_domains does not have to exactly match the number
        # of Teamserver instances.  For details, see:
        # https://www.terraform.io/docs/language/functions/element.html
        cert_read_role_arn  = module.email_sending_domain_certreadrole[element(var.email_sending_domains, count.index)].role.arn
        create_dest_dirs    = false
        full_chain_pem_dest = local.full_chain_pem
        priv_key_pem_dest   = local.priv_key_pem
        # Certbot stores wildcard certs in a directory with the name
        # of the domain, instead of pre-pending an asterisk.
        server_fqdn = element(var.email_sending_domains, count.index)
    })
    content_type = "text/x-shellscript"
    filename     = "01-install-certificates.py"
  }

  # Add https-certificate section to CobaltStrike profiles
  part {
    content = templatefile(
      "${path.module}/cloud-init/add-https-certificate-block-to-cs-profiles.tpl.sh", {
        c2_profile_location = "/tools/Malleable-C2-Profiles/normal"
        domain              = element(var.email_sending_domains, count.index)
        full_chain_pem      = local.full_chain_pem
        priv_key_pem        = local.priv_key_pem
    })
    content_type = "text/x-shellscript"
    filename     = "02-add-https-certificate-block-to-cs-profiles.sh"
  }
}
