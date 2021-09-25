# Private DNS A record for Samba server instances
resource "aws_route53_record" "samba_A" {
  count    = lookup(var.operations_instance_counts, "samba", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "samba${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.samba[count.index].private_ip]
}
