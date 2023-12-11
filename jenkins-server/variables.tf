variable "ami_name" {
  description = "The AMI for the Jenkins server instance"
}

variable "ami_id" {
  description = "The ID of the AMI"
  # type = string 
  # default = "ami-0230bd60aa48260c6"
}

variable "ami_key_pair_name" {
  description = "The SSH public key name to associate with the Jenkins instance"
}