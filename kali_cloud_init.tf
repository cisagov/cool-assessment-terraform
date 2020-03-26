# cloud-init commands for configuring Kali instances

data "template_cloudinit_config" "kali_cloud_init_tasks" {
  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to
  # name the mime-parts of the user-data.  They do not affect the
  # final name for the templates. For any x-shellscript parts, the
  # filenames will also be used as a filename in the scripts
  # directory.

  part {
    content = templatefile(
      "${path.module}/cloud-init/create-mount-point.tpl.sh", {
        mount_point = "/data"
    })
    content_type = "text/x-shellscript"
    filename     = "create-mount-point.sh"
  }

  part {
    content = templatefile(
      "${path.module}/cloud-init/efs-mount.tpl.yml", {
        # Just mount the EFS mount target in the first private subnet
        efs_id      = aws_efs_mount_target.target[var.private_subnet_cidr_blocks[0]].file_system_id
        mount_point = "/data"
    })
    content_type = "text/cloud-config"
    filename     = "efs_mount.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}
