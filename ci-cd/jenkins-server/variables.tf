variable "ami_name" {
  description = "The AMI for the Jenkins server instance"
  type = string
}

variable "ami_id" {
  description = "The ID of the AMI"
  type = string 
  # default = "ami-0230bd60aa48260c6"
}

variable "ami_key_pair_name" {
  description = "The SSH public key name to associate with the Jenkins instance"
  type = string
}

variable "name" {
  description = "The name prefix of the Jenkins instance IAM role"
  type = string
}

variable "dynamo_db_table" {
  description = "The Dynamo DB table that stores the state lock file"
  type = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 backend bucket"
  type = string
}

variable "path_to_key" {
  description = "The path to the Terraform state key"
  type = string
}