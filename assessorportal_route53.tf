# Private DNS A record for Assessor Portal instances
resource "aws_route53_record" "assessorportal_A" {
  count    = lookup(var.operations_instance_counts, "assessorportal", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "assessorportal${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.assessorportal[count.index].private_ip]
}
