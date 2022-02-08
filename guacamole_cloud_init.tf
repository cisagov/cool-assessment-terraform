# cloud-init commands for configuring Guacamole instance

data "cloudinit_config" "guacamole_cloud_init_tasks" {
  gzip          = true
  base64_encode = true

  #-------------------------------------------------------------------------------
  # Cloud Config parts
  #-------------------------------------------------------------------------------

  # Notes:
  # * All the cloud-config parts will write to the same file on the instance
  # at boot. To prevent one part from clobbering another, you must specify a
  # merge_type.  See:
  # https://cloudinit.readthedocs.io/en/latest/topics/merging.html#built-in-mergers
  # * The filename parameters in each part below are only used to name the
  # mime-parts of the user-data.  It does not affect the final name for the
  # templates.

  # Set environment variables required to enroll in the FreeIPA
  # domain.
  part {
    filename     = "freeipa-vars.yml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/cloud-init/freeipa-vars.tpl.yml", {
        domain   = var.cool_domain
        hostname = "guac.${local.assessment_account_name_base}.${var.cool_domain}"
    })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  #-------------------------------------------------------------------------------
  # Shell script parts
  #-------------------------------------------------------------------------------

  # Note: The filename parameters in each part below are used to name
  # the mime-parts of the user-data as well as the filename in the
  # scripts directory.

  part {
    filename     = "install-certificates.py"
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/cloud-init/install-certificates.tpl.py", {
        aws_region          = var.aws_region
        cert_bucket_name    = var.cert_bucket_name
        cert_read_role_arn  = module.guacamole_certreadrole.role.arn
        create_dest_dirs    = true
        full_chain_pem_dest = "/var/guacamole/httpd/ssl/self.cert"
        priv_key_pem_dest   = "/var/guacamole/httpd/ssl/self-ssl.key"
        server_fqdn         = local.guacamole_fqdn
    })
  }
}
