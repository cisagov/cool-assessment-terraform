# Private DNS A record for Debian desktop instances
resource "aws_route53_record" "debiandesktop_A" {
  count    = lookup(var.operations_instance_counts, "debiandesktop", 0)
  provider = aws.provisionassessment

  name    = "debiandesktop${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.debiandesktop[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
