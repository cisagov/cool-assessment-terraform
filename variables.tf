# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "assessment_account_name" {
  type        = string
  description = "The name of the AWS account for this assessment (e.g. \"env0\")."
}

variable "operations_subnet_cidr_block" {
  type        = string
  description = "The operations subnet CIDR block for this assessment (e.g. \"10.10.0.0/24\")."
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "The list of private subnet CIDR blocks for this assessment (e.g. [\"10.10.1.0/24\", \"10.10.2.0/24\"])."
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block to use this assessment's VPC (e.g. \"10.224.0.0/21\")."
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_availability_zone" {
  type        = string
  description = "The AWS availability zone to deploy into (e.g. a, b, c, etc.)"
  default     = "a"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the non-global resources for this assessment are to be provisioned (e.g. \"us-east-1\")."
  default     = "us-east-1"
}

variable "cert_bucket_name" {
  type        = string
  description = "The name of the AWS S3 bucket where certificates are stored."
  default     = "cisa-cool-certificates"
}

# TODO: This should be able to be pulled from a remote state
variable "cool_domain" {
  type        = string
  description = "The domain where the COOL resources reside (e.g. \"cool.cyber.dhs.gov\")."
  default     = "cool.cyber.dhs.gov"
}

variable "dns_ttl" {
  type        = number
  description = "The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing."
  default     = 60
}

variable "guac_connection_setup_path" {
  type        = string
  description = "The full path to the dbinit directory where initialization files must be stored in order to work properly. (e.g. \"/var/guacamole/dbinit\")"
  default     = "/var/guacamole/dbinit"
}

variable "operations_instance_counts" {
  type        = map(number)
  description = "A map specifying how many instances of each type should be created in the operations subnet (e.g. { \"kali\": 1 }).  The currently-supported instance keys are: [\"kali\"]."
  default     = { "kali" : 1 }
}

variable "operations_subnet_inbound_tcp_ports_allowed" {
  type        = list(string)
  description = "The list of TCP ports allowed inbound (from anywhere) to the operations subnet (e.g. [\"80\", \"443\"])."
  default     = ["80", "443"]
}

variable "private_domain" {
  type        = string
  description = "The local domain to use for this assessment (e.g. \"env0\"). If not provided, `local.private_domain` will be set to the base of the assessment account name.  For example, if the account name is \"env0 (Staging)\", `local.private_domain` will default to \"env0\".  Note that `local.private_domain` should be used in place of `var.private_domain` throughout this project."
  default     = ""
}

variable "provisionaccount_role_name" {
  type        = string
  description = "The name of the IAM role that allows sufficient permissions to provision all AWS resources in the assessment account."
  default     = "ProvisionAccount"
}

variable "provisionassessment_policy_description" {
  type        = string
  description = "The description to associate with the IAM policy that allows provisioning of the resources required in the assessment account."
  default     = "Allows provisioning of the resources required in the assessment account."
}

variable "provisionassessment_policy_name" {
  type        = string
  description = "The name to assign the IAM policy that allows provisioning of the resources required in the assessment account."
  default     = "ProvisionAssessment"
}

variable "ssm_key_vnc_password" {
  type        = string
  description = "The AWS SSM Parameter Store parameter that contains the password needed to connect to the TBD instance via VNC (e.g. \"/vnc/password\")"
  default     = "/vnc/password"
}

variable "ssm_key_vnc_username" {
  type        = string
  description = "The AWS SSM Parameter Store parameter that contains the username of the VNC user on the TBD instance (e.g. \"/vnc/username\")"
  default     = "/vnc/username"
}

variable "ssm_key_vnc_user_private_ssh_key" {
  type        = string
  description = "The AWS SSM Parameter Store parameter that contains the private SSH key of the VNC user on the TBD instance (e.g. \"/vnc/ssh/rsa_private_key\")"
  default     = "/vnc/ssh/rsa_private_key"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources created"
  default     = {}
}
