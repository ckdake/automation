locals {
  default_bucket_policy_statements = [
    <<EOP1
        {
            "Sid": "DenyNon-HTTPS",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
              "arn:aws:s3:::${var.bucket_name}",
              "arn:aws:s3:::${var.bucket_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
EOP1
  ]
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = local.tags
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = var.bucket_name

  policy = <<EOP
{
    "Version": "2012-10-17",
    "Statement": [
        ${join(",", setunion(local.default_bucket_policy_statements, var.additional_bucket_policy_statements))}
    ]
}
EOP
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Use a customer managed KMS key.
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_kms" {
  count = var.kms_key_arn != "" ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Use AWS default encryption, for AWS services that require it.
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  count = var.kms_key_arn != "" ? 0 : 1

  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = [
      versioning_configuration # Some buckets have this disabled for $ savings. Let them be for now.
    ]
  }
}

resource "aws_s3_bucket_logging" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  target_bucket = var.logging_bucket_name
  target_prefix = "AWSLogs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "rule-1"

    filter {
      prefix = "AWSLogs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    status = "Enabled"
  }
}
