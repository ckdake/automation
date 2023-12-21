# For now, prowler is run by hand as a user via the administrator role. In the future,
# this should be run on a schedule, by a prowler role with dedicated read-only
# permissions and write permissions to Security. See the SecurityAudit policy.

resource "aws_securityhub_product_subscription" "prowler" {
  product_arn = "arn:aws:securityhub:${local.aws_region}::product/prowler/prowler"
}
