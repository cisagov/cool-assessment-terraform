# The instance ID
output "id" {
  value = "${aws_instance.example.id}"
}

# The instance ARN
output "arn" {
  value = "${aws_instance.example.arn}"
}

# The Availability Zone where the instance is deployed
output "availability_zone" {
  value = "${aws_instance.example.availability_zone}"
}

# The private IP of the instance
output "private_ip" {
  value = "${aws_instance.example.private_ip}"
}

# The ID of the subnet where the instance is deployed
output "subnet_id" {
  value = "${aws_instance.example.subnet_id}"
}
