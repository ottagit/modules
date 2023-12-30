# Attach EC2 admin policies to Jenkins IAM role
resource "aws_iam_role_policy" "jenkins_instance" {
  role = aws_iam_role.jenkins_instance.id
  policy = data.aws_iam_policy_document.ec2_admin_permissions.JSON
}