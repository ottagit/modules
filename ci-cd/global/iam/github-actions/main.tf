# Create an IAM OIDC identity provider that trusts GitHub
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Fetch GitHub's OIDC thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Allow the IAM OIDC identity provider to assume the IAM
# role via federated authentication
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      # The repos and branches defined in var.allowed_repos_branches
      # will be able to assume this role
      values = [
        for a in var.allowed_repos_branches :

        "repo:${a["org"]}/${a["repo"]}:ref:refs/heads/${a["branch"]}"
      ]
    }
  }
}

# Create an IAM role and pass it the JSON from the assume_role
# policy document to use as the assume role policy
resource "aws_iam_role" "github_actions" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Define policies to attach to the CI server instance IAM role
data "aws_iam_policy_document" "github_actions_admin_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*", ]
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
    resources = ["arn:aws:dynamodb:*:*:table/${var.dynamo_db_table}"]
  }

  statement {
    sid = "GitHubOIDC"

    effect    = "Allow"
    actions   = [
        # "iam:CreateOpenIDConnectProvider",
        # "iam:GetRole",
        # "iam:GetOpenIDConnectProvider",
        # "iam:GetRolePolicy",
        # "iam:ListRolePolicies",
        "iam:*",
    ]
    resources = [
      # "arn:aws:iam:::oidc-provider/${var.provider-name}",
      # "${aws_iam_role.github_actions.name}",
      "*"
    ]
  }
}

# Attach resource admin policies to CI server IAM role
resource "aws_iam_role_policy" "github_actions" {
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_admin_permissions.json
}