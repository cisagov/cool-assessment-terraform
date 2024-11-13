# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "tf_role_arn" {
  description = "The ARN of the role that can terraform non-specialized resources."
  nullable    = false
  type        = string
}

# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "ami_owner_account_id" {
  default     = "self"
  description = "The ID of the AWS account that owns the AMI, or \"self\" if the AMI is owned by the same account as the provisioner."
  nullable    = false
  type        = string
}

variable "aws_availability_zone" {
  default     = "a"
  description = "The AWS availability zone to deploy into (e.g. a, b, c, etc.)."
  nullable    = false
  type        = string
}

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to deploy into (e.g. us-east-1)."
  nullable    = false
  type        = string
}

variable "tags" {
  default = {
    Testing = true
  }
  description = "Tags to apply to all AWS resources created."
  nullable    = false
  type        = map(string)
}
