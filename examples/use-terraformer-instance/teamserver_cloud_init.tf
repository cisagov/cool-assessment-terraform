# cloud-init commands for configuring teamserver instances

locals {
  # These values are used twice below, so we may as well define them
  # in one place.
  full_chain_pem = "/tmp/fullchain.pem"
  priv_key_pem   = "/tmp/privkey.pem"
}

data "cloudinit_config" "teamserver_cloud_init_tasks" {
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
      "${path.module}/../../cloud-init/efs-mount.tpl.yml", {
        # Just mount the EFS mount target in the first private subnet
        efs_id      = data.terraform_remote_state.cool_assessment_terraform.outputs.efs_mount_targets[data.terraform_remote_state.cool_assessment_terraform.outputs.private_subnet_cidr_blocks[0]].file_system_id
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
      "${path.module}/../../cloud-init/mount-efs-share.tpl.sh", {
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
      "${path.module}/../../cloud-init/install-certificates.py", {
        aws_region          = var.aws_region
        cert_bucket_name    = data.terraform_remote_state.cool_assessment_terraform.outputs.certificate_bucket_name
        cert_read_role_arn  = data.terraform_remote_state.cool_assessment_terraform.outputs.email_sending_domain_certreadrole[var.email_sending_domain].role.arn
        create_dest_dirs    = false
        full_chain_pem_dest = local.full_chain_pem
        priv_key_pem_dest   = local.priv_key_pem
        # Certbot stores wildcard certs in a directory with the name
        # of the domain, instead of pre-pending an asterisk.
        server_fqdn = var.email_sending_domain
    })
    content_type = "text/x-shellscript"
    filename     = "01-install-certificates.py"
  }

  # Add https-certificate section to Cobalt Strike profiles
  part {
    content = templatefile(
      "${path.module}/../../cloud-init/add-https-certificate-block-to-cs-profiles.tpl.sh", {
        c2_profile_location = "/tools/Malleable-C2-Profiles/normal"
        domain              = var.email_sending_domain
        full_chain_pem      = local.full_chain_pem
        priv_key_pem        = local.priv_key_pem
    })
    content_type = "text/x-shellscript"
    filename     = "02-add-https-certificate-block-to-cs-profiles.sh"
  }
}
