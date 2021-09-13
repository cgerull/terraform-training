terraform {
  # Sample backend configuration. Use ../terraform-state to create 
  # S3 bucket and DynamoDB table backend 
  # 
  # backend "s3" {
  #   bucket = "cgerull-terraform-state"
  #   key    = "global/s3/terraform.tfstate"
  #   region = var.aws_region

  #   dynamodb_table = "cgerull-terraform-state"
  #   encrypt        = true
  # }
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
  name = "public-web-access"

  ingress {
    from_port   = var.private_http_port
    to_port     = var.server_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ssh_whitelist" {
  name = "whitelisted-ssh-access"

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["62.251.111.196/32"]
  }
}

resource "aws_security_group" "alb" {
  name = "terraform-training-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow akk outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "web_server" {
  image_id        = var.ubuntu_ami_amd64
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg_web_public.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World from AWS" > index.html
              nohup busybox httpd -f -p ${var.private_http_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_servers" {
  launch_configuration = aws_launch_configuration.web_server.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.web_servers.arn]
  health_check_type = "ELB"
  min_size          = 1
  max_size          = 3

  tag {
    key                 = "Name"
    value               = "terraform-example"
    propagate_at_launch = true
  }
}

resource "aws_lb" "web_server" {
  name               = "terraform-training-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "web_servers" {
  name     = "terraform-training-asg"
  port     = var.server_http_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "web_servers" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }
}
