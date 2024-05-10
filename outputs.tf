output "assessment_private_zone" {
  description = "The private DNS zone for this assessment."
  value       = aws_route53_zone.assessment_private
}

output "assessor_workbench_instance_profile" {
  description = "The instance profile for the Assessor Workbench instances."
  value       = aws_iam_instance_profile.assessorworkbench
}

output "assessor_workbench_instances" {
  description = "The Assessor Workbench instances."
  value       = aws_instance.assessorworkbench
}

output "assessor_workbench_security_group" {
  description = "The security group for the Assessor Workbench instances."
  value       = aws_security_group.assessorworkbench
}

output "aws_region" {
  description = "The AWS region where this assessment environment lives."
  value       = var.aws_region
}

output "certificate_bucket_name" {
  description = "The name of the S3 bucket where certificate information is stored for this assessment."
  value       = var.cert_bucket_name
}

output "cloudwatch_agent_endpoint_client_security_group" {
  description = "A security group for any instances that run the AWS CloudWatch agent.  This security groups allows such instances to communicate with the VPC endpoints that are required by the AWS CloudWatch agent."
  value       = aws_security_group.cloudwatch_agent_endpoint_client
}

output "debian_desktop_instance_profile" {
  description = "The instance profile for the Debian desktop instances."
  value       = aws_iam_instance_profile.debiandesktop
}

output "debian_desktop_instances" {
  description = "The Debian desktop instances."
  value       = aws_instance.debiandesktop
}

output "debian_desktop_security_group" {
  description = "The security group for the Debian desktop instances."
  value       = aws_security_group.debiandesktop
}

output "dynamodb_endpoint_client_security_group" {
  description = "A security group for any instances that wish to communicate with the DynamoDB VPC endpoint."
  value       = aws_security_group.dynamodb_endpoint_client
}

output "ec2_endpoint_client_security_group" {
  description = "A security group for any instances that wish to communicate with the EC2 VPC endpoint."
  value       = aws_security_group.ec2_endpoint_client
}

output "efs_access_points" {
  description = "The access points to control file-system access to the EFS file share."
  value       = aws_efs_access_point.access_point
}

output "efs_client_security_group" {
  description = "A security group that should be applied to all instances that will mount the EFS file share."
  value       = aws_security_group.efs_client
}

output "efs_mount_targets" {
  description = "The mount targets for the EFS file share."
  value       = aws_efs_mount_target.target
}

output "egressassess_instance_profile" {
  description = "The instance profile for the Egress-Assess instances."
  value       = aws_iam_instance_profile.egressassess
}

output "egressassess_instances" {
  description = "The Egress-Assess instances."
  value       = aws_instance.egressassess
}

output "egressassess_security_group" {
  description = "The security group for the Egress-Assess instances."
  value       = aws_security_group.egressassess
}

output "email_sending_domain_certreadroles" {
  description = "The IAM roles that allow for reading the certificate for each email-sending domain."
  value       = module.email_sending_domain_certreadrole
}

output "gophish_instance_profiles" {
  description = "The instance profiles for the Gophish instances."
  value       = aws_iam_instance_profile.gophish
}

output "gophish_instances" {
  description = "The Gophish instances."
  value       = aws_instance.gophish
}

output "gophish_security_group" {
  description = "The security group for the Gophish instances."
  value       = aws_security_group.gophish
}

output "guacamole_accessible_security_group" {
  description = "A security group that should be applied to all instances that are to be accessible from Guacamole."
  value       = aws_security_group.guacamole_accessible
}

output "guacamole_server" {
  description = "The AWS EC2 instance hosting Guacamole."
  value       = aws_instance.guacamole
}

output "kali_instance_profile" {
  description = "The instance profile for the Kali instances."
  value       = aws_iam_instance_profile.kali
}

output "kali_instances" {
  description = "The Kali instances."
  value       = aws_instance.kali
}

output "kali_security_group" {
  description = "The security group for the Kali instances."
  value       = aws_security_group.kali
}

output "nessus_instance_profile" {
  description = "The instance profile for the Nessus instances."
  value       = aws_iam_instance_profile.nessus
}

output "nessus_instances" {
  description = "The Nessus instances."
  value       = aws_instance.nessus
}

output "nessus_security_group" {
  description = "The security group for the Nessus instances."
  value       = aws_security_group.nessus
}

output "operations_subnet" {
  description = "The operations subnet."
  value       = aws_subnet.operations
}

output "operations_subnet_acl" {
  description = "The access control list (ACL) for the operations subnet."
  value       = aws_network_acl.operations
}

output "pentest_portal_instance_profile" {
  description = "The instance profile for the Pentest Portal instances."
  value       = aws_iam_instance_profile.pentestportal
}

output "pentest_portal_instances" {
  description = "The Pentest Portal instances."
  value       = aws_instance.pentestportal
}

output "pentest_portal_security_group" {
  description = "The security group for the Pentest Portal instances."
  value       = aws_security_group.pentestportal
}

output "private_subnet_cidr_blocks" {
  description = "The private subnet CIDR blocks.  These are used to index into the private_subnets and efs_mount_targets outputs."
  value       = var.private_subnet_cidr_blocks
}

output "private_subnet_nat_gateway" {
  description = "The NAT gateway for the private subnets."
  value       = aws_nat_gateway.nat_gw
}

output "private_subnets" {
  description = "The private subnets."
  value       = aws_subnet.private
}

output "private_subnet_acls" {
  description = "The access control lists (ACLs) for the private subnets."
  value       = aws_network_acl.private
}

output "read_terraform_state_module" {
  description = "The IAM policies and role that allow read-only access to the cool-assessment-terraform workspace-specific state in the Terraform state bucket."
  value       = module.read_terraform_state
}

output "remote_desktop_url" {
  description = "The URL of the remote desktop gateway (Guacamole) for this assessment."
  value       = "https://${aws_route53_record.guacamole_A.name}"
}

output "s3_endpoint_client_security_group" {
  description = "A security group for any instances that wish to communicate with the S3 VPC endpoint."
  value       = aws_security_group.s3_endpoint_client
}

output "samba_client_security_group" {
  description = "The security group that should be applied to all instance types that wish to mount the Samba file share being served by the Samba file share server instances."
  value       = aws_security_group.smb_client
}

output "samba_instance_profile" {
  description = "The instance profile for the Samba file share server instances."
  value       = aws_iam_instance_profile.samba
}

output "samba_instances" {
  description = "The Samba file share server instances."
  value       = aws_instance.samba
}

output "samba_server_security_group" {
  description = "The security group for the Samba file share server instances."
  value       = aws_security_group.smb_server
}

output "scanner_security_group" {
  description = "A security group that should be applied to all instance types that perform scanning.  This security group allows egress to anywhere as well as ingress from anywhere via ICMP."
  value       = aws_security_group.scanner
}

output "ssm_agent_endpoint_client_security_group" {
  description = "A security group for any instances that run the AWS SSM agent.  This security group allows such instances to communicate with the VPC endpoints that are required by the AWS SSM agent."
  value       = aws_security_group.ssm_agent_endpoint_client
}

output "ssm_endpoint_client_security_group" {
  description = "A security group for any instances that wish to communicate with the SSM VPC endpoint."
  value       = aws_security_group.ssm_endpoint_client
}

output "ssm_session_role" {
  description = "An IAM role that allows creation of SSM SessionManager sessions to any EC2 instance in this account."
  value       = module.session_manager.ssm_session_role
}

output "sts_endpoint_client_security_group" {
  description = "A security group for any instances that wish to communicate with the STS VPC endpoint."
  value       = aws_security_group.sts_endpoint_client
}

output "teamserver_instance_profiles" {
  description = "The instance profiles for the Teamserver instances."
  value       = aws_iam_instance_profile.teamserver
}

output "teamserver_instances" {
  description = "The Teamserver instances."
  value       = aws_instance.teamserver
}

output "teamserver_security_group" {
  description = "The security group for the Teamserver instances."
  value       = aws_security_group.teamserver
}

output "terraformer_instances" {
  description = "The Terraformer instances."
  value       = aws_instance.terraformer
}

output "terraformer_permissions_boundary_policy" {
  description = "The permissions boundary policy for the Terraformer instances."
  value       = aws_iam_policy.terraformer_permissions_boundary_policy
}

output "terraformer_security_group" {
  description = "The security group for the Terraformer instances."
  value       = aws_security_group.terraformer
}

output "vpc" {
  description = "The VPC for this assessment environment."
  value       = aws_vpc.assessment
}

output "vpn_server_cidr_block" {
  description = "The CIDR block for the COOL VPN."
  value       = local.vpn_server_cidr_block
}

output "windows_instance_profile" {
  description = "The instance profile for the Windows instances."
  value       = aws_iam_instance_profile.windows
}

output "windows_instances" {
  description = "The Windows instances."
  # We are putting a decrypted SSM value in the Terraform state (see
  # aws_ssm_parameter.vnc_public_ssh_key in locals.tf), so Terraform requires
  # us to mark this output as sensitive.  However, since it's just the public
  # SSH key used by Guacamole, we are fine with this.
  sensitive = true
  value     = aws_instance.windows
}

output "windows_security_group" {
  description = "The security group for the Windows instances."
  value       = aws_security_group.windows
}
