output "assessment_private_zone" {
  value       = aws_route53_zone.assessment_private
  description = "The private DNS zone for this assessment."
}

output "assessorportal_security_group" {
  value       = aws_security_group.assessorportal
  description = "The security group for the Assessor Portal instances."
}

output "cloudwatch_and_ssm_agent_security_group" {
  value       = aws_security_group.cloudwatch_and_ssm_agent
  description = "A security group for _all_ instances.  Allows access to the VPC endpoint resources necessary for teh AWS CloudWatch agent and the AWS SSM agent."
}

output "debian_desktop_security_group" {
  value       = aws_security_group.debiandesktop
  description = "The security group for the Debian desktop instances."
}

output "efs_client_security_group" {
  value       = aws_security_group.efs_client
  description = "A security group that should be applied to all instances that will mount the EFS file share."
}

output "efs_mount_targets" {
  value       = aws_efs_mount_target.target
  description = "The mount targets for the EFS file share."
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
  description = "The AWS EC2 instance hosting guacamole."
}

output "kali_security_group" {
  value       = aws_security_group.kali
  description = "The security group for the Kali instances."
}

output "nessus_security_group" {
  value       = aws_security_group.nessus
  description = "The security group for the Nessus instances."
}

output "operations_subnet" {
  value       = aws_subnet.operations
  description = "The operations subnet."
}

output "pentestportal_security_group" {
  value       = aws_security_group.pentestportal
  description = "The security group for the Pentest Portal instances."
}

output "private_subnets" {
  value       = aws_subnet.private
  description = "The private subnets."
}

output "read_terraform_state_module" {
  value       = module.read_terraform_state
  description = "The IAM policies and role that allow read-only access to the cool-assessment-terraform workspace-specific state in the Terraform state bucket."
}

output "remote_desktop_url" {
  value       = "https://${aws_route53_record.guacamole_A.name}"
  description = "The URL of the remote desktop gateway (Guacamole) for this assessment."
}

output "scanner_security_group" {
  value       = aws_security_group.scanner
  description = "A security group that should be applied to all instance types that perform scanning.  This security group allows egress to anywhere as well as ingress from anywhere via ICMP."
}

output "ssm_session_role" {
  value       = aws_iam_role.ssmsession_role
  description = "An IAM role that allows creation of SSM SessionManager sessions to any EC2 instance in this account."
}

output "teamserver_security_group" {
  value       = aws_security_group.teamserver
  description = "The security group for the Teamserver instances."
}
