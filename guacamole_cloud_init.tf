# cloud-init commands for configuring Guacamole instance

data "template_cloudinit_config" "guacamole_cloud_init_tasks" {
  gzip          = true
  base64_encode = true

  # Note: The filename parameters in each part below are only used to name the
  # mime-parts of the user-data.  It does not affect the final name for the
  # templates. For the x-shellscript parts, it will also be used as a filename
  # in the scripts directory.

  part {
    filename     = "install-certificates.py"
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/install-certificates.py", {
        cert_bucket_name   = var.cert_bucket_name
        cert_read_role_arn = module.guacamole_certreadrole.role.arn
        server_fqdn        = local.guacamole_fqdn
    })
  }

  # Set up Guacamole connection to Kali instance
  part {
    filename     = "write-kali-guac-connection-sql-template.yml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/cloud-init/write-guac-connection-sql-template.tpl.yml", {
        sql_template_fullpath = "/root/kali_guacamole_connection_template.sql"
    })
  }

  # Set up Guacamole connection to Kali instance
  # NOTE: Postgres processes initialization files alphabetically, so it's
  # important to name guac_connection_setup_filename so it runs after the
  # file that defines the Guacamole tables and users ("00_initdb.sql").
  # NOTE: Terraform's templatefile() function complains when I pass in a
  # list input, so I convert the list of instance hostnames below to a
  # comma-separated list of strings.  I tried to find a way to avoid
  # doing this, but was unsuccessful.
  part {
    filename     = "render-kali-guac-connection-sql-template.py"
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/render-guac-connection-sql-template.py", {
        aws_region                       = var.aws_region
        guac_connection_setup_filename   = "01_setup_guac_connections"
        guac_connection_setup_path       = var.guac_connection_setup_path
        instance_hostnames               = join(",", aws_route53_record.kali_A[*].name)
        ssm_vnc_read_role_arn            = aws_iam_role.vnc_parameterstorereadonly_role.arn
        ssm_key_vnc_password             = var.ssm_key_vnc_password
        ssm_key_vnc_user                 = var.ssm_key_vnc_username
        ssm_key_vnc_user_private_ssh_key = var.ssm_key_vnc_user_private_ssh_key
        sql_template_fullpath            = "/root/kali_guacamole_connection_template.sql"
    })
  }
}
