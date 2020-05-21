# ------------------------------------------------------------------------------
# Create an SSM Document that allows creation of SSM SessionManager
# sessions in this account.
# ------------------------------------------------------------------------------
module "run_shell_ssm_document" {
  source = "gazoakley/session-manager-settings/aws"

  providers = {
    aws = aws.provisionassessment
  }
}
