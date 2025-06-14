resource "aws_instance" "task_mgmt" {
  launch_template {
    id      = aws_launch_template.task_mgmt.id
    version = "$Latest"
  }

  tags = {
    Name = "${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      tags["Patch Group"]
    ]
  }
}

resource "aws_launch_template" "task_mgmt" {
  name_prefix = "${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt-ec2-launch-template"

  # Instance
  image_id      = var.ec2_ami_id
  instance_type = "c5.large"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 100
      volume_type = "gp3"
      throughput  = 125
      iops        = 3000
      encrypted   = false
    }
  }

  # Network
  network_interfaces {
    subnet_id       = var.private_subnets[0]
    security_groups = [var.ec2_sg_id]
  }

  # IAM Role
  iam_instance_profile {
    arn = aws_iam_instance_profile.task_mgmt.arn
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(templatefile("${path.module}/resources/setup_task_mgmt.sh", {
    trusted_domain_entry = replace("https://${local.task_mgmt_subdomain_prefix}.${var.base_domain_name}", "*.", "")
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt"
    }
  }

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }
}
