variable "name" {
  description = "The name prefix of the CI instance IAM role"
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

variable "provider-name" {
  description = "The name of the OIDC provider"
  type = string
}