terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create security groups
resource "aws_security_group" "sg_web_public" {
  name = "Public web access"

  ingress {
    from_port   = var.private_http_port
    to_port     = var.server_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ssh_whitelist" {
  name = "Whitelisted ssh access"

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["62.251.111.196/32"]
  }
}

resource "aws_instance" "web_server" {
  ami                     = var.ubuntu_ami_amd64
  instance_type           = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.sg_web_public.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World from AWS" > index.html
              nohup busybox httpd -f -p ${var.private_http_port} &
              EOF

  tags = {
    owner       = "claus"
    name        = "terraform-example"
    environment = "training"
  }
}