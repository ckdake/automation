module "terraform_state_bucket" {
  source = "../../modules/s3-bucket"
  providers = {
    aws = aws
  }

  bucket_name         = "ithought-terraform"
  logging_bucket_name = module.terraform_logging_bucket.id
  kms_key_arn         = aws_kms_key.management.arn
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-lock"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.management.arn
  }
}
