locals {
  aws_cloudtrail_bucket_name = "ithought-aws-cloudtrail"
}

data "aws_iam_policy_document" "assume_cloudtrail_to_cloudwatch" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  name = "cloudtrail-to-cloudwatch"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume_cloudtrail_to_cloudwatch.json
}

resource "aws_iam_policy" "allows_cloudtrail_to_cloudwatch" {
  name        = "cloudtrail-to-cloudwatch"
  description = "allows cloudtrail to publish to cloudwatch"
  path        = "/service-role/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream20141101",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:ithought-org-cloudtrail:log-stream:${local.account_id}_CloudTrail_${local.aws_region}*",
                "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:ithought-org-cloudtrail:log-stream:o-lo17jogrml_*"
            ]
        },
        {
            "Sid": "AWSCloudTrailPutLogEvents20141101",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:ithought-org-cloudtrail:log-stream:${local.account_id}_CloudTrail_${local.aws_region}*",
                "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:ithought-org-cloudtrail:log-stream:o-lo17jogrml_*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allows_cloudtrail_to_cloudwatch" {
  role       = aws_iam_role.cloudtrail_to_cloudwatch.id
  policy_arn = aws_iam_policy.allows_cloudtrail_to_cloudwatch.arn
}

resource "aws_cloudwatch_log_group" "ithought_org_cloudtrail" {
  retention_in_days = 365
  name              = "ithought-org-cloudtrail"
}

module "aws_cloudtrail_bucket" {
  source = "../../modules/s3-bucket"

  bucket_name         = local.aws_cloudtrail_bucket_name
  logging_bucket_name = local.s3_access_log_bucket_name

  additional_bucket_policy_statements = [
    <<EOP1
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${local.aws_cloudtrail_bucket_name}",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudtrail:${local.aws_region}:${local.account_id}:trail/ithought-org"
                }
            }
        }
EOP1
    ,
    <<EOP2
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.aws_cloudtrail_bucket_name}/AWSLogs/${local.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "AWS:SourceArn": "arn:aws:cloudtrail:${local.aws_region}:${local.account_id}:trail/ithought-org"
                }
            }
        }
EOP2
    ,
    <<EOP3
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.aws_cloudtrail_bucket_name}/AWSLogs/o-lo17jogrml/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "AWS:SourceArn": "arn:aws:cloudtrail:${local.aws_region}:${local.account_id}:trail/ithought-org"
                }
            }
        }
EOP3
  ]
}


resource "aws_cloudtrail" "cloudtrail" {
  name                          = "ithought-org"
  s3_bucket_name                = local.aws_cloudtrail_bucket_name
  s3_key_prefix                 = ""
  include_global_service_events = true
  is_organization_trail         = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cloudwatch.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.ithought_org_cloudtrail.arn}:*" # CloudTrail requires the Log Stream wildcard

  kms_key_id = aws_kms_key.management.arn

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  insight_selector {
    insight_type = "ApiErrorRateInsight"
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }
}
