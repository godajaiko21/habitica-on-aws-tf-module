locals {
  account_id                   = data.aws_caller_identity.current.account_id
  default_tags                 = data.aws_default_tags.current.tags
  task_mgmt_subdomain_prefix = "habitica"
}

data "aws_caller_identity" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "current" {}
data "aws_elb_service_account" "elb_service_account" {}
data "aws_default_tags" "current" {}
