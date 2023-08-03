resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 32
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true

  password_reuse_prevention = 24
  max_password_age          = 90
}

# Role to be used for any administrative tasks
data "aws_iam_policy_document" "administrator_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.ckdake.arn]
    }
  }
}

resource "aws_iam_role" "administrator" {
  name               = "administrator"
  assume_role_policy = data.aws_iam_policy_document.administrator_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "administrator_gets_administrator" {
  role       = aws_iam_role.administrator.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Group of users allowed to assume the administrator role
# TODO(ckdake): figure out the right way to enforce MFA with auth pattern
# tfsec:ignore:aws-iam-enforce-group-mfa
resource "aws_iam_group" "administrators" {
  name = "administrators"
}

resource "aws_iam_group_membership" "administrators" {
  name  = "administrators"
  group = aws_iam_group.administrators.name

  users = [
    aws_iam_user.ckdake.name,
  ]
}

resource "aws_iam_policy" "admin_assumption" {
  name        = "admin-assumption"
  description = "allow assuming the admin role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.administrator.arn
    }]
  })
}

resource "aws_iam_group_policy_attachment" "admin_assumption" {
  group      = aws_iam_group.administrators.name
  policy_arn = aws_iam_policy.admin_assumption.arn
}

# Single user that can only assume to the administrator role
resource "aws_iam_user" "ckdake" {
  name          = "ckdake"
  force_destroy = true
  depends_on    = [aws_iam_group.administrators]
}

resource "aws_iam_user_login_profile" "ckdake" {
  user                    = aws_iam_user.ckdake.name
  password_length         = 32
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}
