# Terraform "Compliant Organization" module for AWS

## Opinionated

Gets an org spun up that is compliant with security standards.

All "child" accounts should be created with terraform, and use
the `compliant-account` module too.

## Has some costs

* AWS Config
* Security Hub
* KMS
