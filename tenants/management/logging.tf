locals {
  s3_access_log_bucket_name = "ithought-s3-access-logs"
  aws_logs_bucket_name      = "ithought-aws-logs"
}

module "s3_access_log_bucket" {
  source = "../../modules/s3-bucket"
  providers = {
    aws = aws
  }

  bucket_name         = local.s3_access_log_bucket_name
  logging_bucket_name = local.s3_access_log_bucket_name
  kms_key_arn         = aws_kms_key.management.arn
}

module "aws_logs" {
  source = "../../modules/s3-bucket"
  providers = {
    aws = aws
  }

  bucket_name         = local.aws_logs_bucket_name
  logging_bucket_name = local.s3_access_log_bucket_name
}
