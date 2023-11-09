output "arn" {
  description = "The EC2 instance ARN."
  value       = aws_instance.example.arn
}

output "availability_zone" {
  description = "The AZ where the EC2 instance is deployed."
  value       = aws_instance.example.availability_zone
}

output "id" {
  description = "The EC2 instance ID."
  value       = aws_instance.example.id
}

output "private_ip" {
  description = "The private IP of the EC2 instance."
  value       = aws_instance.example.private_ip
}

output "subnet_id" {
  description = "The ID of the subnet where the EC2 instance is deployed."
  value       = aws_instance.example.subnet_id
}
