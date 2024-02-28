variable "db_name" {
  description = "The name of the database"
  type = string
  default = null
}

variable "db_username" {
  description = "The username of the database"
  type = string
  sensitive = true
  default = null
}

variable "db_password" {
  description = "The database of the database"
  type = string
  sensitive = true
  default = null
}

variable "backup_retention_period" {
  description = "Days to retain backups. Must be > 0 to enable replication"
  type = number
  default = null
}

variable "replicate_source_db" {
  description = "If specified, replicate the RDS DB at the given ARN"
  type = string
  default = null
}