# cloud-init commands for configuring Terraformer instances

data "cloudinit_config" "terraformer_cloud_init_tasks" {
  count = lookup(var.operations_instance_counts, "terraformer", 0)

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
        fqdn     = "terraformer${count.index}.${aws_route53_zone.assessment_private.name}"
        hostname = "terraformer${count.index}"
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
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Create a credentials file for the VNC user that can be used to
  # configure the AWS CLI to assume the Terraformer role by default
  # and other roles by selecting the correct profile.  For details,
  # see
  # https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html#using-a-configuration-file
  #
  # Input variables are:
  # * assessor_account_role_arn - the ARN of an IAM role that can be
  #   assumed to create, delete, and modify AWS resources in a
  #   separate assessor-owned AWS account
  # * aws_region - the AWS region where the roles are to be assumed
  # * permissions - the octal permissions to assign the AWS
  #   configuration
  # * read_cool_assessment_terraform_state_role_arn - the ARN of the
  #   IAM role that can be assumed to read the Terraform state of the
  #   cisagov/cool-assessment-terraform root module
  # * organization_read_role_arn - the ARN of the IAM role that can be
  #   assumed to read information about the AWS Organization to which
  #   the assessment environment belongs
  # * terraformer_role_arn - the ARN of the Terraformer role, which can
  #   be assumed to create certain resources in the assessment
  #   environment
  # * vnc_username - the username associated with the VNC user
  part {
    content = templatefile(
      "${path.module}/cloud-init/write-terraformer-aws-config.tpl.sh", {
        assessor_account_role_arn                     = var.assessor_account_role_arn
        aws_region                                    = var.aws_region
        permissions                                   = "0400"
        read_cool_assessment_terraform_state_role_arn = module.read_terraform_state.role.arn
        organization_read_role_arn                    = data.terraform_remote_state.master.outputs.organizationsreadonly_role.arn
        terraformer_role_arn                          = aws_iam_role.terraformer_role.arn
        vnc_username                                  = data.aws_ssm_parameter.vnc_username.value
    })
    content_type = "text/x-shellscript"
    filename     = "write-terraformer-aws-config.sh"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  # Create a credentials file for the VNC user that can be used to configure
  # the AWS CLI to write to the assessment artifact export S3 bucket.
  # For details, see
  # https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html#using-a-configuration-file
  #
  # Input variables are:
  # * aws_access_key_id - the AWS access key ID
  # * aws_region - the AWS region of the access key
  # * aws_secret_access_key - the AWS secret access key
  # * permissions - the permissions to assign the AWS configuration, specified
  #   in either the octal or symbolic formats understood by chmod
  # * vnc_username - the username associated with the VNC user
  dynamic "part" {
    # Only include this block if var.assessment_artifact_export_enabled is true
    # and there are no Kali instances in this environment.  If there is at least
    # one Kali instance, it should be used for assessment artifact export
    # instead of a Terraformer instance.
    for_each = var.assessment_artifact_export_enabled && lookup(var.operations_instance_counts, "kali", 0) == 0 ? [0] : []

    content {
      content = templatefile(
        "${path.module}/cloud-init/write-aws-config-artifact-export.tpl.sh", {
          aws_access_key_id     = data.aws_ssm_parameter.artifact_export_access_key_id[0].value
          aws_region            = data.aws_ssm_parameter.artifact_export_region[0].value
          aws_secret_access_key = data.aws_ssm_parameter.artifact_export_secret_access_key[0].value
          permissions           = "0400"
          vnc_username          = data.aws_ssm_parameter.vnc_username.value
      })
      content_type = "text/x-shellscript"
      filename     = "write-aws-config-artifact-export.sh"
      merge_type   = "list(append)+dict(recurse_array)+str()"
    }
  }

  # Create a script for the VNC user that can be used to create an archive
  # of the assessment artifacts and copy it to the assessment artifact export
  # S3 bucket.
  #
  # Input variables are:
  # * artifact_export_bucket_name - the name of the assessment artifact export S3
  #   bucket
  # * artifact_export_path - the path to copy the artifact to in the S3 bucket
  # * assessment_id - the identifier for the assessment
  # * permissions - the permissions to assign the script, specified in either
  #   the octal or symbolic formats understood by chmod
  # * vnc_username - the username associated with the VNC user
  dynamic "part" {
    # Only include this block if var.assessment_artifact_export_enabled is true
    # and there are no Kali instances in this environment.  If there is at least
    # one Kali instance, it should be used for assessment artifact export
    # instead of a Terraformer instance.
    for_each = var.assessment_artifact_export_enabled && lookup(var.operations_instance_counts, "kali", 0) == 0 ? [0] : []

    content {
      content = templatefile(
        "${path.module}/cloud-init/write-archive-artifact-data-to-bucket.tpl.sh", {
          artifact_export_bucket_name = data.aws_ssm_parameter.artifact_export_bucket_name[0].value
          artifact_export_path        = var.assessment_artifact_export_map[var.assessment_type]
          assessment_id               = var.assessment_id
          permissions                 = "0500"
          vnc_username                = data.aws_ssm_parameter.vnc_username.value
      })
      content_type = "text/x-shellscript"
      filename     = "write-archive-artifact-data-to-bucket.sh"
      merge_type   = "list(append)+dict(recurse_array)+str()"
    }
  }
}
