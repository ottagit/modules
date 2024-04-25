locals {
  ssh_port = 22
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

  # Render the user data script as a an exposed variable
  user_data = var.user_data

  // Required when using a launch configuration with an ASG
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name = var.cluster_name

  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

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
