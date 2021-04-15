# cloud-init commands for configuring GoPhish instances

data "cloudinit_config" "gophish_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to
  # name the mime-parts of the user-data.  They do not affect the
  # final name for the templates. For any x-shellscript parts, the
  # filenames will also be used as a filename in the scripts
  # directory.

  # Create an fstab entry for the EFS share
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

  # Configure postfix in the pca-gophish Docker composition.
  part {
    content = templatefile(
      "${path.module}/cloud-init/postfix-setup.tpl.yml", {
        email_sending_domain    = var.email_sending_domain
        pca_docker_compose_file = "/var/pca/pca-gophish-composition/docker-compose.yml"
    })
    content_type = "text/cloud-config"
    filename     = "postfix-setup.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}
