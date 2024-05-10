# Private DNS A record for Teamserver instances
resource "aws_route53_record" "teamserver_A" {
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  name    = "teamserver${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.teamserver[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
