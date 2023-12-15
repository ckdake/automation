locals {
  alarm_namespace = "CISBenchmarkAlarms"
}

# Copied/adapted on https://github.com/in4it/terraform-aws-cis-controls
#https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html


resource "aws_sns_topic" "cis_benchmark_alarms" {
  name              = "cis-benchmark-alarms"
  kms_master_key_id = aws_kms_key.management.id

  application_failure_feedback_role_arn = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  application_success_feedback_role_arn = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  firehose_failure_feedback_role_arn    = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  firehose_success_feedback_role_arn    = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  http_failure_feedback_role_arn        = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  http_success_feedback_role_arn        = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  lambda_failure_feedback_role_arn      = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  lambda_success_feedback_role_arn      = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  sqs_failure_feedback_role_arn         = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
  sqs_success_feedback_role_arn         = aws_iam_role.sns_delivery_status_to_cloudwatch.arn
}

resource "aws_sns_topic_subscription" "topic_email_subscription" {
  topic_arn = aws_sns_topic.cis_benchmark_alarms.arn
  protocol  = "email"
  endpoint  = "ckdake@ckdake.com"
}


# 1.1 – Avoid the use of the "root" account
resource "aws_cloudwatch_log_metric_filter" "aws_cis_1_1_avoid_the_use_of_root_account" {
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  name           = "RootAccountUsage"
  pattern        = "{ $.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\" }"
  metric_transformation {
    name      = "RootAccountUsage"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_cis_1_1_avoid_the_use_of_root_account" {
  alarm_description         = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
  alarm_name                = "CIS-1.1-RootAccountUsage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  insufficient_data_actions = []
  metric_name               = aws_cloudwatch_log_metric_filter.aws_cis_1_1_avoid_the_use_of_root_account.id
  namespace                 = local.alarm_namespace
  ok_actions                = []
  period                    = 300
  statistic                 = "Sum"
  alarm_actions             = [aws_sns_topic.cis_benchmark_alarms.arn]
  threshold                 = 1
  treat_missing_data        = "notBreaching"
}

# 3.1 – Ensure a log metric filter and alarm exist for unauthorized API calls 
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "UnauthorizedAPICalls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "UnauthorizedAPICalls"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "CIS-3.1-UnauthorizedAPICalls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring unauthorized API calls will help reveal application errors and may reduce time to detect malicious activity."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.2 – Ensure a log metric filter and alarm exist for AWS Management Console sign-in without MFA 
resource "aws_cloudwatch_log_metric_filter" "no_mfa_console_signin" {
  name           = "NoMFAConsoleSignin"
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\") }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "NoMFAConsoleSignin"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "no_mfa_console_signin" {
  alarm_name          = "CIS-3.2-ConsoleSigninWithoutMFA"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.no_mfa_console_signin.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring for single-factor console logins will increase visibility into accounts that are not protected by MFA."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.3 – Ensure a log metric filter and alarm exist for usage of "root" account 
resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "RootUsage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "RootUsage"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_usage" {
  alarm_name          = "CIS-3.3-RootAccountUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.root_usage.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.4 – Ensure a log metric filter and alarm exist for IAM policy changes 
resource "aws_cloudwatch_log_metric_filter" "iam_changes" {
  name           = "IAMChanges"
  pattern        = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "IAMChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_changes" {
  alarm_name          = "CIS-3.4-IAMPolicyChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.iam_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to IAM policies will help ensure authentication and authorization controls remain intact."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.5 – Ensure a log metric filter and alarm exist for CloudTrail configuration changes
resource "aws_cloudwatch_log_metric_filter" "cloudtrail_cfg_changes" {
  name           = "CloudTrailCfgChanges"
  pattern        = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "CloudTrailCfgChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_cfg_changes" {
  alarm_name          = "CIS-3.5-CloudTrailChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.cloudtrail_cfg_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to CloudTrail's configuration will help ensure sustained visibility to activities performed in the AWS account."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.6 – Ensure a log metric filter and alarm exist for AWS Management Console authentication failures 
resource "aws_cloudwatch_log_metric_filter" "console_signin_failures" {
  name           = "ConsoleSigninFailures"
  pattern        = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "ConsoleSigninFailures"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_signin_failures" {
  alarm_name          = "CIS-3.6-ConsoleAuthenticationFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.console_signin_failures.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.7 – Ensure a log metric filter and alarm exist for disabling or scheduled deletion of customer created CMKs 
resource "aws_cloudwatch_log_metric_filter" "disable_or_delete_cmk" {
  name           = "DisableOrDeleteCMK"
  pattern        = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName = DisableKey) || ($.eventName = ScheduleKeyDeletion)) }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "DisableOrDeleteCMK"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "disable_or_delete_cmk" {
  alarm_name          = "CIS-3.7-DisableOrDeleteCMK"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.disable_or_delete_cmk.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.8 – Ensure a log metric filter and alarm exist for S3 bucket policy changes 
resource "aws_cloudwatch_log_metric_filter" "s3_bucket_policy_changes" {
  name           = "S3BucketPolicyChanges"
  pattern        = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "S3BucketPolicyChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_bucket_policy_changes" {
  alarm_name          = "CIS-3.8-S3BucketPolicyChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.s3_bucket_policy_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to S3 bucket policies may reduce time to detect and correct permissive policies on sensitive S3 buckets."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.9 – Ensure a log metric filter and alarm exist for AWS Config configuration changes 
resource "aws_cloudwatch_log_metric_filter" "aws_config_changes" {
  name           = "AWSConfigChanges"
  pattern        = "{ ($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder)) }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id

  metric_transformation {
    name      = "AWSConfigChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_config_changes" {
  alarm_name          = "CIS-3.9-AWSConfigChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.aws_config_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to AWS Config configuration will help ensure sustained visibility of configuration items within the AWS account."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.10 – Ensure a log metric filter and alarm exist for security group changes 
resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  name           = "SecurityGroupChanges"
  pattern        = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  alarm_name          = "CIS-3.10-SecurityGroupChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.security_group_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to security group will help ensure that resources and services are not unintentionally exposed."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.11 – Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL) 
resource "aws_cloudwatch_log_metric_filter" "nacl_changes" {
  name           = "NACLChanges"
  pattern        = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "NACLChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl_changes" {
  alarm_name          = "CIS-3.11-NetworkACLChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.nacl_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to NACLs will help ensure that AWS resources and services are not unintentionally exposed."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_log_metric_filter" "network_gw_changes" {
  name           = "NetworkGWChanges"
  pattern        = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id

  metric_transformation {
    name      = "NetworkGWChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

# 3.12 – Ensure a log metric filter and alarm exist for changes to network gateways 
resource "aws_cloudwatch_metric_alarm" "network_gw_changes" {
  alarm_name          = "CIS-3.12-NetworkGatewayChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.network_gw_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to network gateways will help ensure that all ingress/egress traffic traverses the VPC border via a controlled path."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_log_metric_filter" "route_table_changes" {
  name           = "RouteTableChanges"
  pattern        = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "RouteTableChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

# 3.13 – Ensure a log metric filter and alarm exist for route table changes 
resource "aws_cloudwatch_metric_alarm" "route_table_changes" {
  alarm_name          = "CIS-3.13-RouteTableChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.route_table_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to route tables will help ensure that all VPC traffic flows through an expected path."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}

# 3.14 – Ensure a log metric filter and alarm exist for VPC changes 
resource "aws_cloudwatch_log_metric_filter" "vpc_changes" {
  name           = "VPCChanges"
  pattern        = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
  log_group_name = aws_cloudwatch_log_group.ithought_org_cloudtrail.id
  metric_transformation {
    name      = "VPCChanges"
    namespace = local.alarm_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc_changes" {
  alarm_name          = "CIS-3.14-VPCChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.vpc_changes.id
  namespace           = local.alarm_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Monitoring changes to VPC will help ensure that all VPC traffic flows through an expected path."
  alarm_actions = [
    aws_sns_topic.cis_benchmark_alarms.arn
  ]
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}
