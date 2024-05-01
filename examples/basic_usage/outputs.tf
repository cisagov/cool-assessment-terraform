output "arn" {
  description = "The EC2 instance ARN."
  value       = module.example.arn
}

output "availability_zone" {
  description = "The AZ where the EC2 instance is deployed."
  value       = module.example.availability_zone
}

output "id" {
  description = "The EC2 instance ID."
  value       = module.example.id
}

output "private_ip" {
  description = "The private IP of the EC2 instance."
  value       = module.example.private_ip
}

output "subnet_id" {
  description = "The ID of the subnet where the EC2 instance is deployed."
  value       = module.example.subnet_id
}
