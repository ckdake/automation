locals {
  confirmed_management_kms_key_arn = var.management_kms_key_arn == "" ? aws_kms_key.management[0].arn : var.management_kms_key_arn
}
