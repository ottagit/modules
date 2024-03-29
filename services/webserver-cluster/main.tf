terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Define local values visible within this module
locals {
  http_port = 80
  any_port = 0
  ssh_port = 22
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

/** create a launch configuration that specifies how to 
configure each EC2 instance in the ASG **/
resource "aws_launch_configuration" "example" {
  image_id = var.ami
  instance_type = var.instance_type
  key_name = "web-cluster"
  // resource attribute reference
  security_groups = [aws_security_group.instance.id]

  # Render the user data script as a template
  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  })

  // Required when using a launch configuration with an ASG
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name = var.cluster_name

  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  # Use instance refresh to roll out changes to the ASG
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key = "Name"
    value = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      # Filter out any key set to Name because the module already sets its
      # own Name tag
      for key, value in var.custom_tags: key => upper(value) if key != "Name"
    }

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

# Define a scheduled action
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_auto_scaling ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 4
  desired_capacity = 4
  recurrence = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_auto_scaling ? 1 : 0

  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 3
  desired_capacity = 3
  recurrence = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_lb" "example" {
  name = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = local.http_port
  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name = "${var.cluster_name}-asg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

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
  listener_arn = aws_lb_listener.http.arn
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

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_http_inbound_instance" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port = var.server_port
  to_port = var.server_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# Allow SSH connections
resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port = local.ssh_port
  to_port = local.ssh_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

 # Allow inbound security requests
resource "aws_security_group_rule" "allow_http_inbound_alb" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# Allow all outbound requests
resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the web server to read the outputs from the DB state file
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}