variable aws_region {
  description = "AWS region name."
  type = string
  default = "eu-west-1"
}
variable vpc_cidr_block {
  description = "AWS VPC CIDR block."
  type = string
  default = "10.0.0.0/16"
}