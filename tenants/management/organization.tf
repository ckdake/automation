resource "aws_organizations_account" "management" {
  name      = "management"
  email     = "ckdake@ckdake.com"
  parent_id = module.compliant_organization.root_organization_id
}

resource "aws_organizations_organizational_unit" "test" {
  name      = "test"
  parent_id = module.compliant_organization.root_organization_id
}

resource "aws_organizations_account" "test1" {
  name      = "test1"
  email     = "ckdake+test1@ckdake.com"
  parent_id = aws_organizations_organizational_unit.test.id
}

resource "aws_organizations_account" "test2" {
  name      = "test2"
  email     = "ckdake+test2@ckdake.com"
  parent_id = aws_organizations_organizational_unit.test.id
}
