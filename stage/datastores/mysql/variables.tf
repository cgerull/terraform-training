variable "aws_region" {
  description = "AWS region name."
  type        = string
  default     = "eu-west-1"
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
