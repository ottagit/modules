output "public_ip" {
  description = "The public IP for the Jenkins instance"
  value = aws_instance.jenkins-instance.public_ip
}