# Private DNS A record for Assessor Workbench instances
resource "aws_route53_record" "assessorworkbench_A" {
  count    = lookup(var.operations_instance_counts, "assessorworkbench", 0)
  provider = aws.provisionassessment

  name    = "assessorworkbench${count.index}.${aws_route53_zone.assessment_private.name}"
  records = [aws_instance.assessorworkbench[count.index].private_ip]
  ttl     = var.dns_ttl
  type    = "A"
  zone_id = aws_route53_zone.assessment_private.zone_id
}
