# Define policies to attach to the Jenkins instance IAM role
data "aws_iam_policy_document" "ec2_admin_permissions" {
  statement {
    effect = "Allow"
    actions = ["ec2:*"]
    resources = ["*"]
  }
}