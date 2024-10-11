resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # AWS no longer requires these for Github Actions, but we must
  # provide something for terraform to apply cleanly.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

data "aws_iam_policy_document" "github_actions_assumes_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test = "StringLike"
      values = [
        for repository_name in var.repository_names : repository_name
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      type        = "Federated"
    }
  }

  version = "2012-10-17"
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assumes_role.json
  description        = "Role assumed by GitHub Actions"
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count = length(var.policy_attachment_arns)

  role       = aws_iam_role.github_actions.name
  policy_arn = var.policy_attachment_arns[count.index]
}
