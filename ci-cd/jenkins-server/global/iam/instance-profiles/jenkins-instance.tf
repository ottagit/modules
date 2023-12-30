# Allow the Jenkins instance to automatically assume the
# Jenkins instance IAM role
resource "aws_iam_instance_profile" "jenkins_instance" {
  role = aws_iam_role.jenkins_instance.name
}