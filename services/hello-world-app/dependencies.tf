# Use the count parameter to optionally create the three
# data sources based on whether their corresponding input
# variable is set to null

data "aws_vpc" "default" {
  count = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.subnet_ids == null ? 1 : 0
  filter {
    name = "vpc-id"
    values = [local.vpc_id]
  }
}

# Get the web server to read the outputs from the DB state file
data "terraform_remote_state" "db" {
  count = var.mysql_config == null ? 1 : 0

  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}