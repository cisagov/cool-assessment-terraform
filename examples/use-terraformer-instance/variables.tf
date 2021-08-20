# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "The AWS region where the non-global resources for this assessment are to be provisioned (e.g. \"us-east-1\")."
  default     = "us-east-1"
}

variable "dns_ttl" {
  type        = number
  description = "The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing."
  default     = 60
}

variable "email_sending_domain" {
  type        = string
  description = "The domain to send emails from within the assessment environment (e.g. \"example.com\")."
  default     = "example.com"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources created"
  default     = {}
}
