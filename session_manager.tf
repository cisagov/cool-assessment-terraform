# ------------------------------------------------------------------------------
# Provision SSM Session Manager and configure it for session logging.
# ------------------------------------------------------------------------------

module "session_manager" {
  depends_on = [
    aws_iam_role_policy_attachment.provisionssmsessionmanager_policy_attachment
  ]
  providers = {
    aws = aws.provisionassessment
  }
  source = "github.com/cisagov/session-manager-tf-module"

  cloudwatch_log_group_name = var.session_cloudwatch_log_group_name
  other_accounts = [
    local.users_account_id,
  ]
}
