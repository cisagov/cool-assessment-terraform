output "assessment_private_zone" {
  value       = aws_route53_zone.assessment_private
  description = "The private DNS zone for this assessment."
}

output "assessor_portal_instance_profile" {
  value       = aws_iam_instance_profile.assessorportal
  description = "The instance profile for the Assessor Portal instances."
}

output "assessor_portal_instances" {
  value       = aws_instance.assessorportal
  description = "The Assessor Portal instances."
}

output "assessor_portal_security_group" {
  value       = aws_security_group.assessorportal
  description = "The security group for the Assessor Portal instances."
}

output "aws_region" {
  value       = var.aws_region
  description = "The AWS region where this assessment environment lives."
}

output "certificate_bucket_name" {
  value       = var.cert_bucket_name
  description = "The name of the S3 bucket where certificate information is stored for this assessment."
}

output "cloudwatch_agent_endpoint_client_security_group" {
  value       = aws_security_group.cloudwatch_agent_endpoint_client
  description = "A security group for any instances that run the AWS CloudWatch agent.  This security groups allows such instances to communicate with the VPC endpoints that are required by the AWS CloudWatch agent."
}

output "debian_desktop_instance_profile" {
  value       = aws_iam_instance_profile.debiandesktop
  description = "The instance profile for the Debian desktop instances."
}

output "debian_desktop_instances" {
  value       = aws_instance.debiandesktop
  description = "The Debian desktop instances."
}

output "debian_desktop_security_group" {
  value       = aws_security_group.debiandesktop
  description = "The security group for the Debian desktop instances."
}

output "dynamodb_endpoint_client_security_group" {
  value       = aws_security_group.dynamodb_endpoint_client
  description = "A security group for any instances that wish to communicate with the DynamoDB VPC endpoint."
}

output "ec2_endpoint_client_security_group" {
  value       = aws_security_group.ec2_endpoint_client
  description = "A security group for any instances that wish to communicate with the EC2 VPC endpoint."
}

output "efs_access_points" {
  value       = aws_efs_access_point.access_point
  description = "The access points to control file-system access to the EFS file share."
}

output "efs_client_security_group" {
  value       = aws_security_group.efs_client
  description = "A security group that should be applied to all instances that will mount the EFS file share."
}

output "efs_mount_targets" {
  value       = aws_efs_mount_target.target
  description = "The mount targets for the EFS file share."
}

output "email_sending_domain_certreadroles" {
  value       = module.email_sending_domain_certreadrole
  description = "The IAM roles that allow for reading the certificate for each email-sending domain."
}

output "gophish_instance_profiles" {
  value       = aws_iam_instance_profile.gophish
  description = "The instance profiles for the Gophish instances."
}

output "gophish_instances" {
  value       = aws_instance.gophish
  description = "The Gophish instances."
}

output "gophish_security_group" {
  value       = aws_security_group.gophish
  description = "The security group for the Gophish instances."
}

output "guacamole_accessible_security_group" {
  value       = aws_security_group.guacamole_accessible
  description = "A security group that should be applied to all instances that are to be accessible from Guacamole."
}

output "guacamole_server" {
  value       = aws_instance.guacamole
  description = "The AWS EC2 instance hosting Guacamole."
}

output "kali_instance_profile" {
  value       = aws_iam_instance_profile.kali
  description = "The instance profile for the Kali instances."
}

output "kali_instances" {
  value       = aws_instance.kali
  description = "The Kali instances."
}

output "kali_security_group" {
  value       = aws_security_group.kali
  description = "The security group for the Kali instances."
}

output "nessus_instance_profile" {
  value       = aws_iam_instance_profile.nessus
  description = "The instance profile for the Nessus instances."
}

output "nessus_instances" {
  value       = aws_instance.nessus
  description = "The Nessus instances."
}

output "nessus_security_group" {
  value       = aws_security_group.nessus
  description = "The security group for the Nessus instances."
}

output "nomachine_accessible_security_group" {
  value       = aws_security_group.nomachine_accessible
  description = "The security group for the instances that are accessible via NoMachine."
}

output "operations_subnet" {
  value       = aws_subnet.operations
  description = "The operations subnet."
}

output "operations_subnet_acl" {
  value       = aws_network_acl.operations
  description = "The access control list (ACL) for the operations subnet."
}

output "pentest_portal_instance_profile" {
  value       = aws_iam_instance_profile.pentestportal
  description = "The instance profile for the Pentest Portal instances."
}

output "pentest_portal_instances" {
  value       = aws_instance.pentestportal
  description = "The Pentest Portal instances."
}

output "pentest_portal_security_group" {
  value       = aws_security_group.pentestportal
  description = "The security group for the Pentest Portal instances."
}

output "private_subnet_cidr_blocks" {
  value       = var.private_subnet_cidr_blocks
  description = "The private subnet CIDR blocks.  These are used to index into the private_subnets and efs_mount_targets outputs."
}

output "private_subnet_nat_gateway" {
  value       = aws_nat_gateway.nat_gw
  description = "The NAT gateway for the private subnets."
}

output "private_subnets" {
  value       = aws_subnet.private
  description = "The private subnets."
}

output "private_subnet_acls" {
  value       = aws_network_acl.private
  description = "The access control lists (ACLs) for the private subnets."
}

output "read_terraform_state_module" {
  value       = module.read_terraform_state
  description = "The IAM policies and role that allow read-only access to the cool-assessment-terraform workspace-specific state in the Terraform state bucket."
}

output "remote_desktop_url" {
  value       = "https://${aws_route53_record.guacamole_A.name}"
  description = "The URL of the remote desktop gateway (Guacamole) for this assessment."
}

output "s3_endpoint_client_security_group" {
  value       = aws_security_group.s3_endpoint_client
  description = "A security group for any instances that wish to communicate with the S3 VPC endpoint."
}

output "samba_client_security_group" {
  value       = aws_security_group.smb_client
  description = "The security group that should be applied to all instance types that wish to mount the Samba file share being served by the Samba file share server instances."
}

output "samba_instance_profile" {
  value       = aws_iam_instance_profile.samba
  description = "The instance profile for the Samba file share server instances."
}

output "samba_instances" {
  value       = aws_instance.samba
  description = "The Samba file share server instances."
}

output "samba_server_security_group" {
  value       = aws_security_group.smb_server
  description = "The security group for the Samba file share server instances."
}

output "scanner_security_group" {
  value       = aws_security_group.scanner
  description = "A security group that should be applied to all instance types that perform scanning.  This security group allows egress to anywhere as well as ingress from anywhere via ICMP."
}

output "ssm_agent_endpoint_client_security_group" {
  value       = aws_security_group.ssm_agent_endpoint_client
  description = "A security group for any instances that run the AWS SSM agent.  This security group allows such instances to communicate with the VPC endpoints that are required by the AWS SSM agent."
}

output "ssm_endpoint_client_security_group" {
  value       = aws_security_group.ssm_endpoint_client
  description = "A security group for any instances that wish to communicate with the SSM VPC endpoint."
}

output "ssm_session_role" {
  value       = module.session_manager.ssm_session_role
  description = "An IAM role that allows creation of SSM SessionManager sessions to any EC2 instance in this account."
}

output "sts_endpoint_client_security_group" {
  value       = aws_security_group.sts_endpoint_client
  description = "A security group for any instances that wish to communicate with the STS VPC endpoint."
}

output "teamserver_instance_profiles" {
  value       = aws_iam_instance_profile.teamserver
  description = "The instance profiles for the Teamserver instances."
}

output "teamserver_instances" {
  value       = aws_instance.teamserver
  description = "The Teamserver instances."
}

output "teamserver_security_group" {
  value       = aws_security_group.teamserver
  description = "The security group for the Teamserver instances."
}

output "terraformer_instances" {
  value       = aws_instance.terraformer
  description = "The Terraformer instances."
}

output "terraformer_security_group" {
  value       = aws_security_group.terraformer
  description = "The security group for the Terraformer instances."
}

output "vpc" {
  value       = aws_vpc.assessment
  description = "The VPC for this assessment environment."
}

output "vpn_server_cidr_block" {
  value       = local.vpn_server_cidr_block
  description = "The CIDR block for the COOL VPN."
}

output "windows_instance_profile" {
  value       = aws_iam_instance_profile.windows
  description = "The instance profile for the Windows instances."
}

output "windows_instances" {
  value       = aws_instance.windows
  description = "The Windows instances."
}

output "windows_security_group" {
  value       = aws_security_group.windows
  description = "The security group for the Windows instances."
}
