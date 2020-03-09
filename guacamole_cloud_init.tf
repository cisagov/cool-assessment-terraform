# cloud-init commands for configuring Guacamole instance

data "template_cloudinit_config" "guacamole_cloud_init_tasks" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/install-certificates.py", {
        cert_bucket_name   = var.cert_bucket_name
        cert_read_role_arn = module.guacamole_certreadrole.role.arn
        server_fqdn        = local.guacamole_fqdn
    })
  }

  # TODO: Make this more generalized and able to support a variety of connections
  part {
    filename     = "write-guac-connection-sql-template.yml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/cloud-init/write-guac-connection-sql-template.tpl.yml", {
        guac_connection_name  = var.guac_connection_name
        private_domain        = var.private_domain
        sql_template_fullpath = "/root/guacamole_connection_template.sql"
    })
  }

  # TODO: Make this more generalized and able to support a variety of connections
  part {
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/render-guac-connection-sql-template.py", {
        aws_region                       = var.aws_region
        guac_connection_setup_filename   = var.guac_connection_setup_filename
        guac_connection_setup_path       = var.guac_connection_setup_path
        ssm_vnc_read_role_arn            = aws_iam_role.vnc_parameterstorereadonly_role.arn
        ssm_key_vnc_password             = var.ssm_key_vnc_password
        ssm_key_vnc_user                 = var.ssm_key_vnc_username
        ssm_key_vnc_user_private_ssh_key = var.ssm_key_vnc_user_private_ssh_key
        sql_template_fullpath            = "/root/guacamole_connection_template.sql"
    })
  }
}
