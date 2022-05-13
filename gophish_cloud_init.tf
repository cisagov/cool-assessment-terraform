# cloud-init commands for configuring Gophish instances

locals {
  # This value is used multiple times below, so we may as well define it
  # in one place.
  pca_gophish_composition_dir = "/var/pca/pca-gophish-composition"
}

data "cloudinit_config" "gophish_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "gophish", 0)

  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to
  # name the mime-parts of the user-data.  They do not affect the
  # final name for the templates. For any x-shellscript parts, the
  # filenames will also be used as a filename in the scripts
  # directory.

  # Set the local hostname
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
        fqdn     = "gophish${count.index}.${aws_route53_zone.assessment_private.name}"
        hostname = "gophish${count.index}"
    })
    content_type = "text/cloud-config"
    filename     = "set-hostname.yml"
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

  # Install certificate for postfix.
  part {
    content = templatefile(
      "${path.module}/cloud-init/install-certificates.tpl.py", {
        aws_region       = var.aws_region
        cert_bucket_name = var.cert_bucket_name
        # We use the element() function below instead of the built-in list
        # index syntax because we want the "wrap-around" behavior provided
        # by element().  This means that the number of items in
        # var.email_sending_domains does not have to exactly match the number
        # of Gophish instances.  For details, see:
        # https://www.terraform.io/docs/language/functions/element.html
        cert_read_role_arn  = module.email_sending_domain_certreadrole[element(var.email_sending_domains, count.index)].role.arn
        create_dest_dirs    = false
        full_chain_pem_dest = "${local.pca_gophish_composition_dir}/secrets/postfix/fullchain.pem"
        priv_key_pem_dest   = "${local.pca_gophish_composition_dir}/secrets/postfix/privkey.pem"
        # Certbot stores wildcard certs in a directory with the name
        # of the domain, instead of pre-pending an asterisk.
        server_fqdn = element(var.email_sending_domains, count.index)
    })
    content_type = "text/x-shellscript"
    filename     = "install-certificates-postfix.py"
  }

  # Configure postfix in the pca-gophish Docker composition.
  part {
    content = templatefile(
      "${path.module}/cloud-init/postfix-setup.tpl.yml", {
        email_sending_domain    = element(var.email_sending_domains, count.index)
        pca_docker_compose_file = "${local.pca_gophish_composition_dir}/docker-compose.yml"
    })
    content_type = "text/cloud-config"
    filename     = "postfix-setup.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Install certificate for Gophish.
  part {
    content = templatefile(
      "${path.module}/cloud-init/install-certificates.tpl.py", {
        aws_region       = var.aws_region
        cert_bucket_name = var.cert_bucket_name
        # We use the element() function below instead of the built-in list
        # index syntax because we want the "wrap-around" behavior provided
        # by element().  This means that the number of items in
        # var.email_sending_domains does not have to exactly match the number
        # of Gophish instances.  For details, see:
        # https://www.terraform.io/docs/language/functions/element.html
        cert_read_role_arn  = module.email_sending_domain_certreadrole[element(var.email_sending_domains, count.index)].role.arn
        create_dest_dirs    = false
        full_chain_pem_dest = "${local.pca_gophish_composition_dir}/secrets/gophish/phish_fullchain.pem"
        priv_key_pem_dest   = "${local.pca_gophish_composition_dir}/secrets/gophish/phish_privkey.pem"
        # Certbot stores wildcard certs in a directory with the name
        # of the domain, instead of pre-pending an asterisk.
        server_fqdn = element(var.email_sending_domains, count.index)
    })
    content_type = "text/x-shellscript"
    filename     = "install-certificates-gophish.py"
  }

  # Configure Thunderbird to autoconfigure email accounts from the
  # appropriate email-sending domain.
  part {
    content = templatefile(
      "${path.module}/cloud-init/write-thunderbird-email-autoconfig.tpl.yml", {
        email_sending_domain = element(var.email_sending_domains, count.index)
    })
    content_type = "text/cloud-config"
    filename     = "write-thunderbird-email-autoconfig.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Ensure email-sending domain is mapped to 127.0.0.1 in /etc/hosts.
  # Note: Even though /etc/hosts on this instance is managed by cloud-init
  # in /etc/cloud/templates/hosts.debian.tmpl, we can safely modify
  # /etc/hosts here because our change will be applied at every startup,
  # after the earlier cloud-init code applies hosts.debian.tmpl.
  part {
    content = templatefile(
      "${path.module}/cloud-init/map-hostname-to-localhost.tpl.sh", {
        hostname   = element(var.email_sending_domains, count.index)
        hosts_file = "/etc/hosts"
    })
    content_type = "text/x-shellscript"
    filename     = "map-hostname-to-localhost.sh"
  }
}
