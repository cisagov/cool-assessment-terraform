#-------------------------------------------------------------------------------
# Turn on flow logs for the VPC.
#-------------------------------------------------------------------------------
module "vpc_flow_logs" {
  source = "trussworks/vpc-flow-logs/aws"

  vpc_name       = local.assessment_account_name_base
  vpc_id         = aws_vpc.assessment.id
  logs_retention = "365"
}
