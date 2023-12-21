resource "aws_organizations_organization" "root" {
  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "health.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "storage-lens.s3.amazonaws.com"
  ]

  feature_set = "ALL"
}
