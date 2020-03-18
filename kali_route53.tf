# Private DNS A record for Kali instance
resource "aws_route53_record" "kali_A" {
  count    = var.operations_instance_counts["kali"]
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "kali${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.kali[count.index].private_ip]
}
