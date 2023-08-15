locals {
  logging_bucket_name = "ithought-s3-access-logs"
}

module "terraform_logging_bucket" {
  source = "../../modules/s3-bucket"
  providers = {
    aws = aws
  }

  bucket_name         = local.logging_bucket_name
  logging_bucket_name = local.logging_bucket_name
  kms_key_arn         = aws_kms_key.management.arn
}
