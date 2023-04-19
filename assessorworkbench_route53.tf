# Private DNS A record for Assessor Workbench instances
resource "aws_route53_record" "assessorworkbench_A" {
  count    = lookup(var.operations_instance_counts, "assessorworkbench", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "assessorworkbench${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.assessorworkbench[count.index].private_ip]
}
