terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "primary"
}

provider "aws" {
  region = "ap-south-1"
  alias = "replica"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "example-db"
  allocated_storage = 10
  instance_class = "db.m5.large"
  skip_final_snapshot = true
  # Enable backups
  backup_retention_period = var.backup_retention_period
  # if specified, this DB will be a replica
  replicate_source_db = var.replicate_source_db

  # Only set these params if replicate_source_db is not specified
  engine = var.replicate_source_db == null ? "mysql" : null
  db_name = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null

  # Set DB password
  password = var.db_password
}