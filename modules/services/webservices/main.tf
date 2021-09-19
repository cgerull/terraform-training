# terraform {
#   # Sample backend configuration. 
#   # Use ../terraform-state to create the S3 bucket and DynamoDB table backend.backend.
#   # See README.md for more details.
#   # 
#   # backend "s3" {
#   #   bucket = "cgerull-terraform-state"
#   #   key    = "global/s3/terraform.tfstate"
#   #   region = eu-westlocal.any_protocol

#   #   dynamodb_table = "cgerull-terraform-state"
#   #   encrypt        = true
#   # }
#   backend "s3" {
#     bucket   = var.webserver_cluster_remote_state_bucket
#     key = var.webserver_cluster_remote_state_key
#     region = eu-west-1
#   }

#   # required_providers {
#   #   aws = {
#   #     source  = "hashicorp/aws"
#   #     version = "~> 3.56"
#   #   }
#   # }
# }

# Create security groups
resource "aws_security_group" "sg_web_public" {
  name = "${var.cluster_name}-web-access"

  ingress {
    from_port   = var.private_http_port
    to_port     = var.server_http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}

resource "aws_security_group" "sg_ssh_whitelist" {
  name = "${var.cluster_name}-ssh-access"

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = local.tcp_protocol
    cidr_blocks = ["62.251.111.196/32"]
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_launch_configuration" "web_server" {
  image_id        = var.ubuntu_ami_amd64
  instance_type   = var.instance_type
  security_groups = [aws_security_group.sg_web_public.id]
  # user_data       = data.template_file.user_data.rendered
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World from AWS<br>" >> index.html
              echo "Database server: ${data.terraform_remote_state.db.outputs.address}" >> index.html
              echo "${data.terraform_remote_state.db.outputs.port}<br>" >> index.html
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
  min_size          = var.min_size
  max_size          = var.max_size

  tag {
    key                 = "name"
    value               =  var.cluster_name
    propagate_at_launch = true
  }
}

resource "aws_lb" "web_server" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server.arn
  port              = local.http_port
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
  name     = "${var.cluster_name}-asg"
  port     = var.server_http_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
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
