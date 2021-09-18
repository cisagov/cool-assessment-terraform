output "teamserver" {
  value       = aws_instance.teamserver
  description = "The Teamserver instance."
}

output "teamserver_a_record" {
  value       = aws_route53_record.teamserver_A
  description = "The Teamserver A record."
}

output "teamserver_eip" {
  value       = aws_eip.teamserver
  description = "The Teamserver EIP."
}
