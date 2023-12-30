# Create an IAM role and pass it the JSON from the assume_role
# policy document to use as the assume role policy

resource "aws_iam_role" "jenkins-instance" {
  name_prefix = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.JSON
}