# Private DNS A record for Terraformer instances
resource "aws_route53_record" "terraformer_A" {
  count    = lookup(var.operations_instance_counts, "terraformer", 0)
  provider = aws.provisionassessment

  zone_id = aws_route53_zone.assessment_private.zone_id
  name    = "terraformer${count.index}.${aws_route53_zone.assessment_private.name}"
  type    = "A"
  ttl     = var.dns_ttl
  records = [aws_instance.terraformer[count.index].private_ip]
}
