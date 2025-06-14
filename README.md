# habitica-on-aws-tf-module

Terraform module for hosting Habitica on AWS.

## Overview

This module provisions the necessary AWS infrastructure to deploy and run [Habitica](https://github.com/HabitRPG/habitica) in a production-like environment. It automates the setup of networking, compute, load balancing, IAM, SSL, and DNS resources, and includes a setup script for configuring the Habitica application on EC2.

## Features

- **VPC Integration**: Deploys resources into your existing VPC and subnets.
- **EC2 Instance**: Launches and configures an EC2 instance to run Habitica, including all dependencies.
- **Application Load Balancer (ALB)**: Provides HTTPS and HTTP endpoints, with automatic HTTP-to-HTTPS redirection.
- **IAM Roles**: Sets up least-privilege IAM roles and instance profiles for secure operation.
- **Route53 DNS**: Automatically creates DNS records for Habitica.
- **ACM Integration**: Uses AWS Certificate Manager for SSL/TLS certificates.
- **Automated Setup**: Includes a shell script to install and configure Habitica, Node.js, MongoDB, and systemd services.

## Usage

```hcl
module "habitica" {
  source            = "github.com/godajaiko21/habitica-on-aws-tf-module"
  project_id        = "your-project"
  env_id            = "prod"
  region_id         = "ap-northeast-1"
  vpc_id            = "vpc-xxxxxxx"
  public_subnets    = ["subnet-xxxxxx", ...]
  private_subnets   = ["subnet-yyyyyy", ...]
  base_domain_name  = "example.com"
  alb_sg_id         = "sg-xxxxxx"
  ec2_sg_id         = "sg-yyyyyy"
  ec2_ami_id        = "ami-zzzzzz"
}
```

## Variables

| Name              | Type         | Description                                  |
|-------------------|--------------|----------------------------------------------|
| project_id        | string       | Project identifier                           |
| env_id            | string       | Environment identifier (e.g., prod, dev)     |
| region_id         | string       | AWS region identifier                        |
| vpc_id            | string       | VPC ID where resources will be deployed      |
| public_subnets    | list(string) | List of public subnet IDs for ALB            |
| private_subnets   | list(string) | List of private subnet IDs for EC2           |
| base_domain_name  | string       | Base domain name for Route53/ACM             |
| alb_sg_id         | string       | Security group ID for ALB                    |
| ec2_sg_id         | string       | Security group ID for EC2                    |
| ec2_ami_id        | string       | AMI ID for EC2 instance                      |

## Resources Created

- `aws_instance` (EC2 for Habitica)
- `aws_launch_template` (for EC2 configuration)
- `aws_lb` (Application Load Balancer)
- `aws_lb_target_group` and `aws_lb_listener` (for HTTP/HTTPS)
- `aws_iam_role` and `aws_iam_instance_profile` (for EC2)
- `aws_route53_record` (DNS for Habitica)
- `aws_acm_certificate` (SSL certificate lookup)

## Setup Script

The EC2 instance runs `resources/setup_task_mgmt.sh` at launch, which:

- Installs system dependencies, Node.js, and Habitica
- Configures MongoDB and Habitica as systemd services
- Clones the Habitica repository and builds the client
- Sets up trusted domains and environment variables

## Requirements

- Terraform >= 1.9.8
- AWS provider >= 5.74.0
- Existing VPC, subnets, and security groups
- A valid ACM certificate for your domain in the target region

## License

MIT License
