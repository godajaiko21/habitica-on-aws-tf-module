resource "aws_iam_role" "task_mgmt" {
  name               = "${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt-iam-role"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task_mgmt" {
  for_each = {
    ssm    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    s3read = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  role       = aws_iam_role.task_mgmt.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "task_mgmt" {
  name = "${var.project_id}-${var.env_id}-${var.region_id}-task-mgmt-iam-instance-profile"
  role = aws_iam_role.task_mgmt.name
}
