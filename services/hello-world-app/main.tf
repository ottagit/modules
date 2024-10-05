terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Set specific provider version compatible with Terratest
      version = "4.0.0"
    }
  }
}

locals {
  mysql_config = (
    var.mysql_config == null ? data.terraform_remote_state.db[0].outputs : var.mysql_config
  )

  vpc_id = (
    var.vpc_id == null ? data.aws_vpc.default[0].id : var.vpc_id
  )

  subnet_ids = (
    var.subnet_ids == null ? data.aws_subnets.default[0].ids : var.subnet_ids
  )
}

module "asg" {
  source = "github.com/ottagit/modules//cluster/asg-rolling-deploy?ref=v0.7.1"

  cluster_name = "hello-world-${var.environment}"
  ami = var.ami
  instance_type = var.instance_type

  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address = local.mysql_config.address
    db_port = local.mysql_config.port
    server_text = var.server_text
  })

  min_size = var.min_size
  max_size = var.max_size
  enable_auto_scaling = var.enable_auto_scaling

  subnet_ids = local.subnet_ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  # source = "github.com/ottagit/modules//networking/alb?ref=v0.8.2"

  # Use local module reference for test consistency
  source = "../../networking/alb"

  alb_name = "hello-world-${var.environment}"
  subnet_ids = local.subnet_ids
}

resource "aws_lb_target_group" "asg" {
  name = "hello-world-${var.environment}"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = local.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}