# The instance ID
output "id" {
  value = "${module.example.id}"
}

# The instance ARN
output "arn" {
  value = "${module.example.arn}"
}

# The Availability Zone where the instance is deployed
output "availability_zone" {
  value = "${module.example.availability_zone}"
}

# The private IP of the instance
output "private_ip" {
  value = "${module.example.private_ip}"
}

# The ID of the subnet where the instance is deployed
output "subnet_id" {
  value = "${module.example.subnet_id}"
}
