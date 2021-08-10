# cloud-init commands for configuring Terraformer instances

data "cloudinit_config" "terraformer_cloud_init_tasks" {
  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to
  # name the mime-parts of the user-data.  They do not affect the
  # final name for the templates. For any x-shellscript parts, the
  # filenames will also be used as a filename in the scripts
  # directory.

  # Create a configuration file for the VNC user that can be used to
  # configure the AWS CLI to assume the Terraformer role by default.
  # For details, see
  # https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html#using-a-configuration-file
  part {
    content = templatefile(
      "${path.module}/cloud-init/write-aws-config.tpl.yml", {
        aws_region  = var.aws_region
        owner       = "root:root"
        path        = "/home/vnc/.aws/config"
        permissions = "0444"
        role_arn    = aws_iam_role.terraformer_role.arn
    })
    content_type = "text/cloud-config"
    filename     = "write-aws-config.yml"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}
