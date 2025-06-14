data "aws_acm_certificate" "regional" {
  domain = var.base_domain_name
}
