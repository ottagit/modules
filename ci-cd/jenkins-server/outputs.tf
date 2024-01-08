output "public_ip" {
  description = "The public IP for the Jenkins instance"
  value = aws_instance.jenkins_instance.public_ip
}