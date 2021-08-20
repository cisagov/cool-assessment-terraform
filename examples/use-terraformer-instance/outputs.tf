output "teamserver" {
  value       = aws_instance.teamserver
  description = "The teamserver instance."
}

output "teamserver_a_record" {
  value       = aws_route53_record.teamserver_A
  description = "The teamserver A record."
}

output "teamserver_eip" {
  value       = aws_eip.teamserver
  description = "The teamserver EIP."
}
