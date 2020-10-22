# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "subnet_id" {
  type        = string
  description = "The ID of the AWS subnet to deploy into (e.g. subnet-0123456789abcdef0)"
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------
variable "ami_owner_account_id" {
  type        = string
  description = "The ID of the AWS account that owns the Example AMI, or \"self\" if the AMI is owned by the same account as the provisioner."
  default     = "self"
}

variable "aws_availability_zone" {
  type        = string
  description = "The AWS availability zone to deploy into (e.g. a, b, c, etc.)"
  default     = "a"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy into (e.g. us-east-1)"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources created"
  default     = {}
}
