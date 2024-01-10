# cloud-init commands for configuring Nessus instances

data "cloudinit_config" "nessus_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "nessus", 0)

  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to name the
  # mime-parts of the user-data.  It does not affect the final name for the
  # templates. For x-shellscript parts, it will also be used as a filename
  # in the scripts directory.

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
        fqdn     = "nessus${count.index}.${aws_route53_zone.assessment_private.name}"
        hostname = "nessus${count.index}"
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

  part {
    filename     = "nessus-setup.sh"
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/nessus-setup.sh", {
        aws_region                    = var.aws_region
        nessus_activation_code        = var.nessus_activation_codes[count.index]
        nessus_web_server_port        = var.nessus_web_server_port
        ssm_key_nessus_admin_password = var.ssm_key_nessus_admin_password
        ssm_key_nessus_admin_username = var.ssm_key_nessus_admin_username
        ssm_nessus_read_role_arn      = aws_iam_role.nessus_parameterstorereadonly_role.arn
    })
  }
}
