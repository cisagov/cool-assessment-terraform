# Private DNS A record for Teamserver instances
resource "aws_route53_record" "teamserver_A" {
  count    = lookup(var.operations_instance_counts, "teamserver", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "teamserver${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.teamserver[count.index].private_ip]
}
