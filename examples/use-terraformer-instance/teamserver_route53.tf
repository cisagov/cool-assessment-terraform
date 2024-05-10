# Private DNS A record for Teamserver instance
resource "aws_route53_record" "teamserver_A" {
  name    = "my_teamserver.${data.terraform_remote_state.cool_assessment_terraform.outputs.assessment_private_zone.name}"
  records = [aws_instance.teamserver.private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = data.terraform_remote_state.cool_assessment_terraform.outputs.assessment_private_zone.zone_id
}
