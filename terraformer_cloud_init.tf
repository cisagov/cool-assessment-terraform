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
  # * vnc_read_parameter_store_role_arn - the ARN of the role that
  #   grants read-only access to certain VNC-related SSM Parameter Store
  #   parameters, including the VNC username
  # * vnc_username_parameter_name - the name of the SSM Parameter Store
  #   parameter containing the VNC user's username
  part {
    content = templatefile(
      "${path.module}/cloud-init/write-terraformer-aws-config.tpl.sh", {
        assessor_account_role_arn                     = var.assessor_account_role_arn
        aws_region                                    = var.aws_region
        permissions                                   = "0400"
        read_cool_assessment_terraform_state_role_arn = module.read_terraform_state.role.arn
        organization_read_role_arn                    = data.terraform_remote_state.master.outputs.organizationsreadonly_role.arn
        terraformer_role_arn                          = aws_iam_role.terraformer_role.arn
        vnc_read_parameter_store_role_arn             = aws_iam_role.guacamole_parameterstorereadonly_role.arn
        vnc_username_parameter_name                   = var.ssm_key_vnc_username
    })
    content_type = "text/x-shellscript"
    filename     = "write-terraformer-aws-config.sh"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}
