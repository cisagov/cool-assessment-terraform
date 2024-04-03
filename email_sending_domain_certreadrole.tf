# Create roles that allow each instance to read its email-sending domain
# certificate from an S3 bucket.
module "email_sending_domain_certreadrole" {
  for_each = toset(var.email_sending_domains)

  source = "github.com/cisagov/cert-read-role-tf-module?ref=testing%2Fterraform-aws-provider_v5"

  providers = {
    aws = aws.provisioncertreadrole
  }

  account_ids      = [local.assessment_account_id]
  cert_bucket_name = var.cert_bucket_name
  # Certbot stores wildcard certs in a directory with the name of the
  # domain, instead of pre-pending an asterisk.
  hostname = each.value
  # Give role a unique name so that it doesn't conflict with roles created
  # in other workspaces for the same domain.
  role_name = "CertificateReadOnly-%s-${terraform.workspace}"
}
