data "aws_route53_zone" "main" {
  name = replace("${var.base_domain_name}.", "*.", "")
}

resource "aws_route53_record" "task_mgmt" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = replace("${local.task_mgmt_subdomain_prefix}.${var.base_domain_name}.", "*.", "")
  type    = "A"

  alias {
    name                   = aws_lb.task_mgmt_alb.dns_name
    zone_id                = aws_lb.task_mgmt_alb.zone_id
    evaluate_target_health = true
  }
}
