locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = "us-east-1"
}

data "aws_caller_identity" "current" {}
