resource "aws_kms_key" "management" {
  count = var.management_kms_key_arn == "" ? 1 : 0

  description         = "This key is used to encrypt everything management related in this account"
  enable_key_rotation = true

  tags = local.tags
}

resource "aws_kms_alias" "management" {
  count = var.management_kms_key_arn == "" ? 1 : 0

  name          = "alias/management"
  target_key_id = aws_kms_key.management[0].id
}
