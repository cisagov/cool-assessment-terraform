# Private DNS A record for Kali instance
resource "aws_route53_record" "kali_A" {
  count    = lookup(var.operations_instance_counts, "kali", 0)
  provider = aws.provisionassessment

  name    = "kali${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.kali[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
