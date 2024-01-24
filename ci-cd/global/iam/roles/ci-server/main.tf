# Create an IAM role and pass it the JSON from the assume_role
# policy document to use as the assume role policy
resource "aws_iam_role" "ci_server_instance" {
  name_prefix = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Define policies to attach to the CI server instance IAM role
data "aws_iam_policy_document" "ci_server_instance_admin_permissions" {
  statement {
    effect = "Allow"
    actions = ["ec2:*",]
    resources = ["*"]
  }

  statement {
    sid = "S3Backend"

    effect = "Allow"
    actions = [ 
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
     ]

     resources = [ 
        "arn:aws:s3:::${var.s3_bucket_name}",
        "arn:aws:s3:::${var.s3_bucket_name}/${var.path_to_key}",
      ]
  }
  statement {
    sid = "StateLockTable"

    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem*",
      "dynamodb:DeleteItem*",
      "dynamodb:PutItem",
    ]
    resources = [ "arn:aws:dynamodb:*:*:table/${var.dynamo_db_table}" ]
  }

  statement {
    sid = "GitHubOIDC"

    effect = "Allow"
    actions = [ "iam:CreateOpenIDConnectProvider", ]
    resources = [ "arn:aws:iam:::oidc-provider/${var.provider-name}" ]
  }
}

# Attach resource admin policies to CI server IAM role
resource "aws_iam_role_policy" "ci_server_instance" {
  role = aws_iam_role.ci_server_instance.id
  policy = data.aws_iam_policy_document.ci_server_instance_admin_permissions.json
}