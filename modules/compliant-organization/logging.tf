locals {
  s3_access_log_bucket_name = "${var.organization_name}-s3-access-logs"
  aws_logs_bucket_name      = "${var.organization_name}-aws-logs"
}

module "s3_access_log_bucket" {
  source = "../../modules/s3-bucket"
  providers = {
    aws = aws
  }

  bucket_name         = local.s3_access_log_bucket_name
  logging_bucket_name = local.s3_access_log_bucket_name
  # s3 access logs do not support AWS KMS keys, so we have to default to SSE-S3 keys.

  additional_bucket_policy_statements = [
    <<EOP
        {
            "Sid": "S3ServerAccessLogsPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "logging.s3.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${local.s3_access_log_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${local.account_id}"
                }
            }
        }
EOP
  ]
}

module "aws_logs" {
  source = "../../modules/s3-bucket"
  providers = {
    aws = aws
  }

  bucket_name         = local.aws_logs_bucket_name
  logging_bucket_name = local.s3_access_log_bucket_name
  kms_key_arn         = aws_kms_key.management.arn

  additional_bucket_policy_statements = [
    <<EOP1
        {
            "Sid": "S3ServerAccessLogsPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "logging.s3.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${local.aws_logs_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": [
                        ${join(", ", [for s in aws_organizations_organization.root.accounts[*].id : format("%q", s)])}
                    ]
                }
            }
        }
EOP1
    ,
    <<EOP2
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${local.aws_logs_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": [
                        ${join(", ", [for s in aws_organizations_organization.root.accounts[*].id : format("%q", s)])}
                    ]
                }
            }
        }
EOP2
    ,
    <<EOP3
        {
            "Sid": "AWSLogDeliveryCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "s3:GetBucketAcl",
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${local.aws_logs_bucket_name}",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": [
                        ${join(", ", [for s in aws_organizations_organization.root.accounts[*].id : format("%q", s)])}
                    ]
                }
            }
        }
EOP3
  ]
}
