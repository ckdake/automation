resource "aws_securityhub_account" "aws_securityhub" {
  control_finding_generator = "SECURITY_CONTROL"
  enable_default_standards  = false
}

resource "aws_securityhub_organization_admin_account" "aws_securityhub_admin_account" {
  depends_on = [aws_organizations_organization.root]

  admin_account_id = local.account_id
}

# resource "aws_securityhub_standards_subscription" "aws" {
#   depends_on    = [aws_securityhub_account.aws_securityhub]
#   standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
# }

# resource "aws_securityhub_standards_subscription" "cis12" {
#   depends_on    = [aws_securityhub_account.aws_securityhub]
#   standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
# }

# resource "aws_securityhub_standards_subscription" "cis14" {
#   depends_on    = [aws_securityhub_account.aws_securityhub]
#   standards_arn = "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/1.4.0"
# }

# resource "aws_securityhub_standards_subscription" "nist" {
#   depends_on    = [aws_securityhub_account.aws_securityhub]
#   standards_arn = "arn:aws:securityhub:us-east-1::standards/nist-800-53/v/5.0.0"
# }
