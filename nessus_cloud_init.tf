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

  part {
    filename     = "nessus-setup.sh"
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/nessus-setup.sh", {
        aws_region                    = var.aws_region
        nessus_activation_code        = var.nessus_activation_codes[count.index]
        ssm_key_nessus_admin_password = var.ssm_key_nessus_admin_password
        ssm_key_nessus_admin_username = var.ssm_key_nessus_admin_username
        ssm_nessus_read_role_arn      = aws_iam_role.nessus_parameterstorereadonly_role.arn
    })
  }
}
