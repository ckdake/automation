resource "aws_securityhub_account" "aws_securityhub" {
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_organization_admin_account" "aws_securityhub_admin_account" {
  depends_on = [aws_organizations_organization.root]

  admin_account_id = aws_organizations_account.management.id
}
