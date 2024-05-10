# Private DNS A record for Samba server instances
resource "aws_route53_record" "samba_A" {
  count    = lookup(var.operations_instance_counts, "samba", 0)
  provider = aws.provisionassessment

  name    = "samba${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.samba[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
