locals {
  aws_config_bucket_name = "${var.organization_name}-aws-config"
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
      "Resource": "arn:aws:s3:::${local.aws_config_bucket_name}"
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
      "Resource": "arn:aws:s3:::${local.aws_config_bucket_name}"
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
      "Resource": "arn:aws:s3:::${local.aws_config_bucket_name}/AWSLogs/*/Config/*"
    }
EOP3
  ]
}

resource "aws_iam_role" "aws_config_aggregator" {
  name = "AWSConfigAggregator"
  path = "/service-role/"

  assume_role_policy = <<EOP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOP
}

resource "aws_iam_role_policy_attachment" "aws_config_aggregator" {
  role = aws_iam_role.aws_config_aggregator.name
  # AWS Managed Policy
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "organization" {
  name = "${var.organization_name}-org"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.aws_config_aggregator.arn
  }
}
