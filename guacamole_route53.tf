resource "aws_route53_record" "guacamole_A" {
  provider = aws.dns_sharedservices

  zone_id = local.cool_dns_private_zone.zone_id
  name    = "guac.${local.assessment_account_name_base}.${var.cool_domain}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.guacamole.private_ip]
}
