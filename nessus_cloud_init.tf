# cloud-init commands for configuring Nessus instances

data "template_cloudinit_config" "nessus_cloud_init_tasks" {
  count = var.operations_instance_counts["nessus"]

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
        nessus_activation_code = var.nessus_activation_codes[count.index]
        nessus_admin_password  = var.nessus_admin_password
        nessus_admin_username  = var.nessus_admin_username
    })
  }
}
