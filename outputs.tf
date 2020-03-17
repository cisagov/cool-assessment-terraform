output "remote_desktop_url" {
  value       = "https://${aws_route53_record.guacamole_A.name}"
  description = "The URL of the remote desktop gateway (Guacamole) for this assessment."
}
