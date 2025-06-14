resource "aws_lb" "task_mgmt_alb" {
  name               = "${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups                  = [var.alb_sg_id]
  subnets                          = var.public_subnets
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  enable_xff_client_port           = true
  drop_invalid_header_fields       = true
}

data "aws_instances" "task_mgmt" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt"]
  }

  filter {
    name   = "instance-state-name"
    values = ["pending", "running", "stopping", "stopped"]
  }
}

resource "aws_lb_target_group" "task_mgmt_tg_8080" {
  name        = "${var.project_id}-${var.env_id}-${var.region_id}-habitica-tg-8080"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold = 3
    interval          = 30
    timeout           = 3
    enabled           = true
    path              = "/"
    port              = "traffic-port"
    protocol          = "HTTP"
  }
}

resource "aws_lb_listener" "task_mgmt_alb_listner_443" {
  load_balancer_arn = aws_lb.task_mgmt_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.regional.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_mgmt_tg_8080.arn
  }
}

resource "aws_lb_listener" "task_mgmt_alb_listner_80" {
  load_balancer_arn = aws_lb.task_mgmt_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "task_mgmt_8080" {
  count = length(data.aws_instances.task_mgmt.ids) > 0 ? 1 : 0

  target_group_arn = aws_lb_target_group.task_mgmt_tg_8080.arn
  target_id        = data.aws_instances.task_mgmt.ids[0]
  port             = 8080
}
