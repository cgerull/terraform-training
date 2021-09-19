
variable "aws_region" {
  description = "AWS region name."
  type        = string
  default     = "eu-central-1"
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