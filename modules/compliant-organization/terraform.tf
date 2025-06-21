module "terraform_state_bucket" {
  source = "../../modules/s3-bucket"

  providers = {
    aws = aws
  }

  application = var.application
  environment = var.environment

  bucket_name         = "${var.organization_name}-terraform"
  logging_bucket_name = local.s3_access_log_bucket_name
  kms_key_arn         = aws_kms_key.management.arn
}
