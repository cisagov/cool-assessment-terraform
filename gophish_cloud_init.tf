# cloud-init commands for configuring GoPhish instances

data "template_cloudinit_config" "gophish_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to
  # name the mime-parts of the user-data.  They do not affect the
  # final name for the templates. For any x-shellscript parts, the
  # filenames will also be used as a filename in the scripts
  # directory.

  part {
    content = templatefile(
      "${path.module}/cloud-init/efs-mount.tpl.yml", {
        # Just mount the EFS mount target in the first private subnet
        efs_id      = aws_efs_mount_target.target[var.private_subnet_cidr_blocks[0]].file_system_id
        mount_point = "/share"
    })
    content_type = "text/cloud-config"
    filename     = "efs_mount.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Set up everything needed to successfully launch the
  # pca-gophish-composition service.
  part {
    content = templatefile(
      "${path.module}/cloud-init/gophish-dir-setup.tpl.yml", {
        efs_mount_point      = "/share"
        efs_gophish_data_dir = "/share/gophish${count.index}_data"
        gophish_data_dir     = "/var/pca/pca-gophish-composition/data"
        pca_systemd_file     = "/etc/systemd/system/pca-gophish-composition.service"
    })
    content_type = "text/cloud-config"
    filename     = "gophish-dir-setup.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}
