output "id" {
  value       = aws_instance.example.id
  description = "The EC2 instance ID"
}

output "arn" {
  value       = aws_instance.example.arn
  description = "The EC2 instance ARN"
}

output "availability_zone" {
  value       = aws_instance.example.availability_zone
  description = "The AZ where the EC2 instance is deployed"
}

output "private_ip" {
  value       = aws_instance.example.private_ip
  description = "The private IP of the EC2 instance"
}

output "subnet_id" {
  value       = aws_instance.example.subnet_id
  description = "The ID of the subnet where the EC2 instance is deployed"
}
