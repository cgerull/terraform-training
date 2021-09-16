variable "aws_region" {
  description = "AWS region name."
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

variable "vpc_cidr_block" {
  description = "AWS VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}
variable "private_http_port" {
  description = "Incomming http port."
  type        = number
  default     = 8080
}
variable "server_http_port" {
  description = "Server http port."
  type        = number
  default     = 8080
}
variable "ssh_port" {
  description = "SSH port number."
  type        = number
  default     = 22
}
variable "ubuntu_ami_amd64" {
  description = "Ubuntu AMI identifier"
  type        = string
  default     = "ami-0c0e8c8bc308182d5"
}