# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region where the non-global resources for this assessment are to be provisioned (e.g. \"us-east-1\")."
  type        = string
}

variable "dns_ttl" {
  default     = 60
  description = "The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing."
  type        = number
}

variable "efs_mount_point_group" {
  default     = "efs_users"
  description = "The name of the group that should own the EFS share mount point on the deployed instance."
  type        = string
}

variable "efs_mount_point_owner" {
  default     = "vnc"
  description = "The name of the user that should own the EFS share mount point on the deployed instance."
  type        = string
}

variable "email_sending_domain" {
  default     = "example.com"
  description = "The domain to send emails from within the assessment environment (e.g. \"example.com\")."
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to all AWS resources created."
  type        = map(string)
}
