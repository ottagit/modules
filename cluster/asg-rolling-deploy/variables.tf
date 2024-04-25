variable "server_port" {
  description = "The port the servers will use for HTTP requests"
  type = number
  default = 8080
}

variable "server_text" {
  description = "The text returned by the web server"
  type = string
  default = "Another server text!"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
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

variable "enable_auto_scaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "ami" {
  description = "The AMI to run in the cluster"
  type = string
  default = "ami-053b0d53c279acc90"
}

variable "custom_tags" {
  description = "Custom tags to set on the instances in the ASG"
  type = map(string)
  default = {}
}

# Allow module to be used with any VPC and subnets
variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type = list(string)
}

# Configure how the ASG integrates with load balancers
variable "target_group_arns" {
  description = "The ARNS of ELB target groups in which to register instances"
  type = list(string)
  default = [ ]
}

variable "health_check_type" {
  description = "The type of health check to perform; must be one of EC2 or ELB"
  type = string
  default = "EC2"
}

variable "user_data" {
  description = "The user data script to run in each instance at booot"
  type = string
  default = null
}