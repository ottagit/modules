# Create an IAM OIDC identity provider that trusts GitHub
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [ data.tls_certificate.github.certificates[0].sha1_fingerprint ]
}

# Fetch GitHub's OIDC thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Allow the IAM OIDC identity provider to assume the IAM
# role via federated authentication
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    effect = "Allow"
    principals {
      identifiers = [ aws_iam_openid_connect_provider.github_actions.arn ]
      type = "Federated"
    }

    condition {
      test = "StringEquals"
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

module "ci_server_role" {
  source = "github.com/ottagit/modules//ci-cd/global/iam/roles/ci-server?ref=v0.1.3"

  name = "github-action-role"
  dynamo_db_table   = "terraone-locks"
  s3_bucket_name    = "batoto-bitange"
  path_to_key       = "global/iam/github-actions/githuboidc.tfstate"
}