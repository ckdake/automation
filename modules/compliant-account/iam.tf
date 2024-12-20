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

# Role to be used for terraform
data "aws_iam_policy_document" "terraform_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      # TODO(ckdake) convert this to paramater
      identifiers = ["arn:aws:iam::053562908965:user/ckdake"]
    }
  }
}

resource "aws_iam_role" "terraform" {
  name = "terraform"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.terraform_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "terraform_gets_administrator" {
  role       = aws_iam_role.terraform.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
