# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "assessment_account_name" {
  description = "The name of the AWS account for this assessment (e.g. \"env0\")."
  type        = string
}

variable "operations_subnet_cidr_block" {
  description = "The operations subnet CIDR block for this assessment (e.g. \"10.10.0.0/24\")."
  type        = string
}

variable "private_subnet_cidr_blocks" {
  description = "The list of private subnet CIDR blocks for this assessment (e.g. [\"10.10.1.0/24\", \"10.10.2.0/24\"])."
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "The CIDR block to use this assessment's VPC (e.g. \"10.224.0.0/21\")."
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "assessor_account_role_arn" {
  default     = "arn:aws:iam::123456789012:role/Allow_It"
  description = "The ARN of an IAM role that can be assumed to create, delete, and modify AWS resources in a separate assessor-owned AWS account."
  type        = string
}

variable "assessmentfindingsbucketwrite_sharedservices_policy_description" {
  default     = "Allows assumption of the role in the Shared Services account that is allowed to write to the assessment findings bucket."
  description = "The description to associate with the IAM policy that allows assumption of the role in the Shared Services account that is allowed to write to the assessment findings bucket."
  type        = string
}

variable "assessmentfindingsbucketwrite_sharedservices_policy_name" {
  default     = "SharedServices-AssumeAssessmentFindingsBucketWrite"
  description = "The name to assign the IAM policy that allows assumption of the role in the Shared Services account that is allowed to write to the assessment findings bucket."
  type        = string
}

variable "assessment_artifact_export_enabled" {
  default     = false
  description = "Whether or not to enable the export of assessment artifacts to an S3 bucket.  If this is set to true, then the following variables should also be configured appropriately: assessment_artifact_export_map, ssm_key_artifact_export_access_key_id, ssm_key_artifact_export_secret_access_key, ssm_key_artifact_export_bucket_name, and ssm_key_artifact_export_region."
  type        = bool
}

variable "assessment_artifact_export_map" {
  default     = {}
  description = "A map whose keys are assessment types and whose values are the prefixes for what an assessment artifact will be named when it is exported to the S3 bucket contained in the SSM parameter specified by the ssm_key_artifact_export_bucket_name variable (e.g. { \"PenTest\" : \"pentest/PT\", \"Phishing\" : \"phishing/PH\", \"RedTeam\" : \"redteam/RT\" }). Note that prefixes can include a path within the bucket.  For example, if the prefix is \"pentest/PT\" and the assessment ID is \"ASMT1234\", then the corresponding artifact will be exported to \"bucket-name/pentest/PT-ASMT1234.tgz\" when the archive-artifact-data-to-bucket.sh script is run."
  type        = map(string)
}

variable "assessment_id" {
  default     = ""
  description = "The identifier for this assessment (e.g. \"ASMT1234\")."
  type        = string
}

variable "assessment_type" {
  default     = ""
  description = "The type of this assessment (e.g. \"PenTest\")."
  type        = string
}

variable "aws_availability_zone" {
  default     = "a"
  description = "The AWS availability zone to deploy into (e.g. a, b, c, etc.)."
  type        = string
}

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region where the non-global resources for this assessment are to be provisioned (e.g. \"us-east-1\")."
  type        = string
}

variable "cert_bucket_name" {
  default     = "cisa-cool-certificates"
  description = "The name of the AWS S3 bucket where certificates are stored."
  type        = string
}

# TODO: This should be able to be pulled from a remote state
variable "cool_domain" {
  default     = "cool.cyber.dhs.gov"
  description = "The domain where the COOL resources reside (e.g. \"cool.cyber.dhs.gov\")."
  type        = string
}

variable "dns_ttl" {
  default     = 60
  description = "The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing."
  type        = number
}

variable "efs_access_point_gid" {
  default     = 2048
  description = "The group ID that should be used for file-system access to the EFS share (e.g. 2048).  Note that this value should match the GID of any group given ownership of the EFS share mount point."
  type        = number
}

variable "efs_access_point_root_directory" {
  default     = "/assessment_share"
  description = "The non-root path to use as the root directory for the AWS EFS access point that controls EFS access for assessment data sharing."
  type        = string
}

variable "efs_access_point_uid" {
  default     = 2048
  description = "The user ID that should be used for file-system access to the EFS share (e.g. 2048).  Note that this value should match the UID of any user given ownership of the EFS share mount point."
  type        = number
}

variable "efs_users_group_name" {
  default     = "efs_users"
  description = "The name of the POSIX group that should have ownership of a mounted EFS share (e.g. \"efs_users\")."
  type        = string
}

variable "email_sending_domains" {
  default     = ["example.com"]
  description = "The list of domains to send emails from within the assessment environment (e.g. [ \"example.com\" ]).  Teamserver and Gophish instances will be deployed with each sequential domain in the list, so teamserver0 and gophish0 will get the first domain, teamserver1 and gophish1 will get the second domain, and so on.  If there are more Teamserver or Gophish instances than email-sending domains, the domains in the list will be reused in a wrap-around fashion. For example, if there are three Teamservers and only two email-sending domains, teamserver0 will get the first domain, teamserver1 will get the second domain, and teamserver2 will wrap-around back to using the first domain.  Note that all letters in this variable must be lowercase or else an error will be displayed."
  type        = list(string)

  validation {
    # Note that [] actually creates a tuple, which will always compare
    # to false against a list because a list and a tuple are different
    # types.  Therefore the tolist() on the right-hand side is
    # necessary.
    #
    # See here for a brief warning related to this very situation:
    # https://www.terraform.io/language/expressions/operators#equality-operators
    condition     = var.email_sending_domains == tolist([for d in var.email_sending_domains : lower(d)])
    error_message = "All of the values in email_sending_domains must be lowercase."
  }
}

variable "findings_data_bucket_name" {
  default     = ""
  description = "The name of the AWS S3 bucket where findings data is to be written.  The default value is not a valid string for a bucket name, so findings data cannot be written to any bucket unless a value is specified."
  type        = string
}

variable "guac_connection_setup_path" {
  default     = "/var/guacamole/dbinit"
  description = "The full path to the dbinit directory where initialization files must be stored in order to work properly. (e.g. \"/var/guacamole/dbinit\")"
  type        = string
}

variable "iam_users_allowed_to_self_deploy" {
  default     = []
  description = "A list of IAM usernames corresponding to the IAM users in the Users account who are allowed to self-deploy.  E.g., [\"first.last\"]."
  nullable    = false
  type        = list(string)
}

variable "inbound_ports_allowed" {
  default = {
    "assessorworkbench" : [],
    "debiandesktop" : [],
    "egressassess" : [],
    "gophish" : [],
    "kali" : [],
    "nessus" : [],
    "pentestportal" : [],
    "samba" : [],
    "teamserver" : [],
    "terraformer" : [],
    "windows" : [],
  }
  description = "An object specifying the ports allowed inbound (from anywhere) to the various instance types (e.g. {\"assessorworkbench\" : [], \"debiandesktop\" : [], \"egressassess\" : [], \"gophish\" : [], \"kali\": [{\"protocol\": \"tcp\", \"from_port\": 443, \"to_port\": 443}, {\"protocol\": \"tcp\", \"from_port\": 9000, \"to_port\": 9009}], \"nessus\" : [], \"pentestportal\" : [], \"samba\" : [], \"teamserver\" : [], \"terraformer\" : [], \"windows\" : [], })."
  type = object({
    assessorworkbench = list(object({ protocol = string, from_port = number, to_port = number })),
    debiandesktop     = list(object({ protocol = string, from_port = number, to_port = number })),
    egressassess      = list(object({ protocol = string, from_port = number, to_port = number })),
    gophish           = list(object({ protocol = string, from_port = number, to_port = number })),
    kali              = list(object({ protocol = string, from_port = number, to_port = number })),
    nessus            = list(object({ protocol = string, from_port = number, to_port = number })),
    pentestportal     = list(object({ protocol = string, from_port = number, to_port = number })),
    samba             = list(object({ protocol = string, from_port = number, to_port = number })),
    teamserver        = list(object({ protocol = string, from_port = number, to_port = number })),
    terraformer       = list(object({ protocol = string, from_port = number, to_port = number })),
    windows           = list(object({ protocol = string, from_port = number, to_port = number })),
  })
}

variable "nessus_activation_codes" {
  default     = []
  description = "The list of Nessus activation codes (e.g. [\"AAAA-BBBB-CCCC-DDDD\"]). The number of codes in this list should match the number of Nessus instances defined in operations_instance_counts."
  type        = list(string)
}

variable "nessus_web_server_port" {
  default     = 8834
  description = "The port on which the Nessus web server should listen (e.g. 8834)."
  type        = number

  validation {
    condition     = !strcontains(var.nessus_web_server_port, ".") && var.nessus_web_server_port > 0 && var.nessus_web_server_port < 65536
    error_message = "nessus_web_server_port must be an integer between 1 and 65535."
  }
}

variable "operations_instance_counts" {
  default = {
    "assessorworkbench" : 0,
    "debiandesktop" : 0,
    "egressassess" : 0,
    "gophish" : 0,
    "kali" : 1,
    "nessus" : 0,
    "pentestportal" : 0,
    "samba" : 0,
    "teamserver" : 0,
    "terraformer" : 0,
    "windows" : 1,
  }
  description = "A map specifying how many instances of each type should be created in the operations subnet (e.g. { \"assessorworkbench\" : 0, \"debiandesktop\" : 0, \"egressassess\" : 0,\"gophish\" : 0, \"kali\": 1, \"nessus\" : 0, \"pentestportal\" : 0, \"samba\" : 0, \"teamserver\" : 0, \"terraformer\" : 0, \"windows\" : 1, })."
  type = object({
    assessorworkbench = number,
    debiandesktop     = number,
    egressassess      = number,
    gophish           = number,
    kali              = number,
    nessus            = number,
    pentestportal     = number,
    samba             = number,
    teamserver        = number,
    terraformer       = number,
    windows           = number
  })
}

variable "private_domain" {
  default     = ""
  description = "The local domain to use for this assessment (e.g. \"env0\"). If not provided, `local.private_domain` will be set to the base of the assessment account name.  For example, if the account name is \"env0 (Staging)\", `local.private_domain` will default to \"env0\".  Note that `local.private_domain` should be used in place of `var.private_domain` throughout this project."
  type        = string
}

variable "provisionaccount_role_name" {
  default     = "ProvisionAccount"
  description = "The name of the IAM role that allows sufficient permissions to provision all AWS resources in the assessment account."
  type        = string
}

variable "provisionassessment_policy_description" {
  default     = "Allows provisioning of the resources required in the assessment account."
  description = "The description to associate with the IAM policy that allows provisioning of the resources required in the assessment account."
  type        = string
}

variable "provisionassessment_policy_name" {
  default     = "ProvisionAssessment"
  description = "The name to assign the IAM policy that allows provisioning of the resources required in the assessment account."
  type        = string
}

variable "provisionssmsessionmanager_policy_description" {
  default     = "Allows sufficient permissions to provision the SSM Document resource and set up SSM session logging in this assessment account."
  description = "The description to associate with the IAM policy that allows sufficient permissions to provision the SSM Document resource and set up SSM session logging in this assessment account."
  type        = string
}

variable "provisionssmsessionmanager_policy_name" {
  default     = "ProvisionSSMSessionManager"
  description = "The name to assign the IAM policy that allows sufficient permissions to provision the SSM Document resource and set up SSM session logging in this assessment account."
  type        = string
}

variable "publish_egress_ip_addresses" {
  default     = false
  description = "A boolean value that specifies whether EC2 instances in the operations subnet should be tagged to indicate that their public IP addresses may be published.  This is useful for deconfliction purposes.  Publishing these addresses can be done via the code in cisagov/publish-egress-ip-lambda and cisagov/publish-egress-ip-terraform."
  type        = bool
}

variable "read_terraform_state_role_name" {
  default     = "ReadCoolAssessmentTerraformTerraformState-%s"
  description = "The name to assign the IAM role (as well as the corresponding policy) that allows read-only access to the cool-assessment-terraform state in the S3 bucket where Terraform state is stored.  The %s in this name will be replaced by the value of the assessment_account_name variable."
  type        = string
}

variable "read_write_terraform_state_role_name" {
  default     = "ReadWriteCoolAssessmentTerraformTerraformState-%s"
  description = "The name to assign the IAM role (as well as the corresponding policy) that allows read-write access to the cool-assessment-terraform state in the S3 bucket where Terraform state is stored.  The %s in this name will be replaced by the value of the assessment_account_name variable."
  type        = string
}

# This variable is copied over from cisagov/session-manager-tf-module
# so that its value can be specified outside of that module.  This
# allows us to impose a dependency of the module on the policy that
# allows for the creation of its resources; otherwise, this dependency
# will be cyclical.
variable "session_cloudwatch_log_group_name" {
  default     = "/ssm/session-logs"
  description = "The name of the log group into which session logs are to be uploaded."
  type        = string
}

variable "ssm_key_artifact_export_access_key_id" {
  default     = "/assessment_artifact_export/access_key_id"
  description = "The AWS SSM Parameter Store parameter that contains the AWS access key of the IAM user that can write to the assessment artifact export bucket (e.g. \"/assessment_artifact_export/access_key_id\")."
  type        = string
}

variable "ssm_key_artifact_export_bucket_name" {
  default     = "/assessment_artifact_export/bucket"
  description = "The AWS SSM Parameter Store parameter that contains the name of the assessment artifact export bucket (e.g. \"/assessment_artifact_export/bucket\")."
  type        = string
}

variable "ssm_key_artifact_export_region" {
  default     = "/assessment_artifact_export/region"
  description = "The AWS SSM Parameter Store parameter that contains the region of the IAM user (specified via ssm_key_artifact_export_access_key_id) that can write to the assessment artifact export bucket (e.g. \"/assessment_artifact_export/region\")."
  type        = string
}

variable "ssm_key_artifact_export_secret_access_key" {
  default     = "/assessment_artifact_export/secret_access_key"
  description = "The AWS SSM Parameter Store parameter that contains the AWS secret access key of the IAM user that can write to the assessment artifact export bucket (e.g. \"/assessment_artifact_export/secret_access_key\")."
  type        = string
}

variable "ssm_key_nessus_admin_password" {
  default     = "/nessus/assessment/admin_password"
  description = "The AWS SSM Parameter Store parameter that contains the password of the Nessus admin user (e.g. \"/nessus/assessment/admin_password\")."
  type        = string
}

variable "ssm_key_nessus_admin_username" {
  default     = "/nessus/assessment/admin_username"
  description = "The AWS SSM Parameter Store parameter that contains the username of the Nessus admin user (e.g. \"/nessus/assessment/admin_username\")."
  type        = string
}

variable "ssm_key_samba_username" {
  default     = "/samba/username"
  description = "The AWS SSM Parameter Store parameter that contains the username of the Samba user (e.g. \"/samba/username\")."
  type        = string
}

variable "ssm_key_vnc_ssh_public_key" {
  default     = "/vnc/ssh/ed25519_public_key"
  description = "The AWS SSM Parameter Store parameter that contains the SSH public key that corresponds to the private SSH key of the VNC user (e.g. \"/vnc/ssh/ed25519_public_key\")."
  type        = string
}

variable "ssm_key_vnc_username" {
  default     = "/vnc/username"
  description = "The AWS SSM Parameter Store parameter that contains the username of the VNC user (e.g. \"/vnc/username\")."
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to all AWS resources created"
  type        = map(string)
}

variable "terraformer_permissions_boundary_policy_description" {
  default     = "The IAM permissions boundary policy attached to the Terraformer instance role in order to protect the foundational resources deployed in this account."
  description = "The description to associate with the IAM permissions boundary policy attached to the Terraformer instance role in order to protect the foundational resources deployed in this account."
  type        = string
}

variable "terraformer_permissions_boundary_policy_name" {
  default     = "TerraformerPermissionsBoundary"
  description = "The name to assign the IAM permissions boundary policy attached to the Terraformer instance role in order to protect the foundational resources deployed in this account."
  type        = string
}

variable "terraformer_role_description" {
  default     = "Allows Terraformer instances to create appropriate AWS resources in this account."
  description = "The description to associate with the IAM role (and policy) that allows Terraformer instances to create appropriate AWS resources in this account."
  type        = string
}

variable "terraformer_role_name" {
  default     = "Terraformer"
  description = "The name to assign the IAM role (and policy) that allows Terraformer instances to create appropriate AWS resources in this account."
  type        = string
}

variable "valid_assessment_id_regex" {
  default     = ""
  description = "A regular expression that specifies valid assessment identifiers (e.g. \"^ASMT[[:digit:]]{4}$\")."
  type        = string
}

variable "valid_assessment_types" {
  # Set the default value to [""] instead of [] to match the default value of
  # var.assessment_type, which is "".  This is done to avoid a validation error
  # when the default values of both variables are used.
  default     = [""]
  description = "A list of valid assessment types (e.g. [\"PenTest\", \"Phishing\", \"RedTeam\"]).  If this list is empty (i.e. []), then any value used for assessment_type will trigger a validation error."
  type        = list(string)
}

variable "windows_with_docker" {
  default     = false
  description = "A boolean to control the instance type used when creating Windows instances to allow Docker Desktop support. Windows instances require the `metal` instance type to run Docker Desktop because of nested virtualization, but if Docker Desktop is not needed then other instance types are fine."
  type        = bool
}
