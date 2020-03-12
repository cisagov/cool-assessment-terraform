# Private DNS A record for Kali instance
resource "aws_route53_record" "kali_A" {
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "kali0.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.kali.private_ip]
}
