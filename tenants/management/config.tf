locals {
  aws_config_bucket_name = "ithought-aws-config"
}

module "aws_config_bucket" {
  source = "../../modules/s3-bucket"

  bucket_name         = local.aws_config_bucket_name
  kms_key_arn         = aws_kms_key.management.arn
  logging_bucket_name = local.s3_access_log_bucket_name

  # Docs for this policy are here: https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-policy.html 
  additional_bucket_policy_statements = [
    <<EOP1
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.aws_config_bucket_name}",
      "Condition": { 
        "StringEquals": {
          "AWS:SourceAccount": "${aws_organizations_account.management.id}"
        }
      }
    }
EOP1
    ,
    <<EOP2
    {
      "Sid": "AWSConfigBucketExistenceCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${local.aws_config_bucket_name}",
      "Condition": { 
        "StringEquals": {
          "AWS:SourceAccount": "${aws_organizations_account.management.id}"
        }
      }
    }
EOP2
    ,
    <<EOP3
    {
      "Sid": "AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.aws_config_bucket_name}/AWSLogs/*/Config/*",
      "Condition": { 
        "StringEquals": { 
          "s3:x-amz-acl": "bucket-owner-full-control",
          "AWS:SourceAccount": "${aws_organizations_account.management.id}"
        }
      }
    }
EOP3
  ]
}

resource "aws_iam_service_linked_role" "aws_service_role_for_config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "aws_config" {
  name     = "aws-config"
  role_arn = aws_iam_service_linked_role.aws_service_role_for_config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "aws_config" {
  name           = "aws-config"
  s3_bucket_name = local.aws_config_bucket_name

  depends_on = [aws_config_configuration_recorder.aws_config]
}

resource "aws_config_configuration_aggregator" "organization" {
  name = "ithought"

  organization_aggregation_source {
    all_regions = true
    role_arn    = "arn:aws:iam::${aws_organizations_account.management.id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
  }
}
