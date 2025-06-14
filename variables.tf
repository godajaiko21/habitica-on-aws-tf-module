variable "project_id" {
  type = string
}
variable "env_id" {
  type = string
}
variable "region_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "base_domain_name" {
  type = string
}
variable "alb_sg_id" {
  type = string
}
variable "ec2_sg_id" {
  type = string
}
variable "ec2_ami_id" {
  type = string
}
