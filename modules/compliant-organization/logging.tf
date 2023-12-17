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
  kms_key_arn         = aws_kms_key.management.arn

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
                    "aws:SourceAccount": "${local.account_id}"
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
               "ArnLike": {
                    "aws:SourceArn": [
                        "arn:aws:logs::${local.account_id}:*",
                        "arn:aws:logs::618006054620:*"
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
               "ArnLike": {
                    "aws:SourceArn": [
                        "arn:aws:logs::${local.account_id}:*",
                        "arn:aws:logs::618006054620:*"
                    ]
                }
            }
        }
EOP3
  ]
}