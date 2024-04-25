variable "alb_name" {
  description = "The name to use for the ALB"
  type = string
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type = list(string)
}