# Private DNS A record for Egress-Assess instances
resource "aws_route53_record" "egressassess_A" {
  count    = lookup(var.operations_instance_counts, "egressassess", 0)
  provider = aws.provisionassessment

  name    = "egressassess${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.egressassess[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
