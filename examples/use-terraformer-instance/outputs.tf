output "teamserver" {
  description = "The Teamserver instance."
  value       = aws_instance.teamserver
}

output "teamserver_a_record" {
  description = "The Teamserver A record."
  value       = aws_route53_record.teamserver_A
}

output "teamserver_eip" {
  description = "The Teamserver EIP."
  value       = aws_eip.teamserver
}
