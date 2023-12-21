resource "aws_organizations_organization" "root" {
  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com"
  ]

  feature_set = "ALL"
}
