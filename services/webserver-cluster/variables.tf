variable "server_port" {
  description = "The port the servers will use for HTTP requests"
  type = number
  default = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in s3"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instance to run"
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
  type = number
}

variable "desired_capacity" {
  description = "The number of EC2 instances that should be running in the ASG"
  type = number
}

variable "custom_tags" {
  description = "Custom tags to set on the instances in the ASG"
  type = map(string)
  default = {}
}

variable "enable_auto_scaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "ami" {
  description = "The AMI to run in the cluster"
  type = string
  default = "ami-053b0d53c279acc90"
}

variable "server_text" {
  description = "The text returned by the web server"
  type = string
  default = "New server text!"
}