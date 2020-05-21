output "remote_desktop_url" {
  value       = "https://${aws_route53_record.guacamole_A.name}"
  description = "The URL of the remote desktop gateway (Guacamole) for this assessment."
}

output "ssm_session_role" {
  value       = aws_iam_role.ssmsession_role
  description = "An IAM role that allows creation of SSM SessionManager sessions to any EC2 instance in this account."
}
