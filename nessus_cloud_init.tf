# cloud-init commands for configuring Nessus instances

data "template_cloudinit_config" "nessus_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "nessus", 0)

  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to name the
  # mime-parts of the user-data.  It does not affect the final name for the
  # templates. For x-shellscript parts, it will also be used as a filename
  # in the scripts directory.

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
