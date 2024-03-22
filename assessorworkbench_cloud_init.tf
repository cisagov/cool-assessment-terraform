# cloud-init commands for configuring Assessor Workbench instances

data "cloudinit_config" "assessorworkbench_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "assessorworkbench", 0)

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
        fqdn     = "assessorworkbench${count.index}.${aws_route53_zone.assessment_private.name}"
        hostname = "assessorworkbench${count.index}"
    })
    content_type = "text/cloud-config"
    filename     = "set-hostname.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # TODO: Remove the following two parts when and if that becomes
  # possible.  See #234 for more details.

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

  # Create the JSON file used to configure Docker daemon.  This allows us
  # to tell Docker to store volume data on our persistent
  # EBS Docker data volume (created below).
  part {
    content = templatefile(
      "${path.module}/cloud-init/write-docker-daemon-json.tpl.yml", {
        docker_data_root_dir = local.docker_volume_mount_point
    })
    content_type = "text/cloud-config"
    filename     = "write-docker-daemon-json.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Prepare and mount EBS volume to hold Docker data-root data.
  # Note that this script and the next one must take place in a certain order,
  # so we prepend numbers to the script names to force that to that happen.
  #
  # Here is where the user scripts are called by cloud-init:
  # https://github.com/canonical/cloud-init/blob/master/cloudinit/config/cc_scripts_user.py#L45
  #
  # And here is where you can see how cloud-init sorts the scripts:
  # https://github.com/canonical/cloud-init/blob/master/cloudinit/subp.py#L373
  part {
    content = templatefile(
      "${path.module}/cloud-init/ebs-disk-setup.tpl.sh", {
        device_name   = local.docker_ebs_device_name
        fs_type       = "ext4"
        label         = "docker_data"
        mount_options = "defaults"
        mount_point   = local.docker_volume_mount_point
        num_disks     = 2
    })
    content_type = "text/x-shellscript"
    filename     = "01-ebs-disk-setup.sh"
  }

  # Copy Docker data from default directory to new data-root directory.
  part {
    content = templatefile(
      "${path.module}/cloud-init/copy-docker-data-to-new-root-dir.tpl.sh", {
        mount_point       = local.docker_volume_mount_point
        new_data_root_dir = local.docker_volume_mount_point
    })
    content_type = "text/x-shellscript"
    filename     = "02-copy-docker-data-to-new-root-dir.sh"
  }
}
