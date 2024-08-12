terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62.0"
    }
  }

  required_version = ">= 1.8.5"

  backend "s3" {
    bucket         = "ithought-terraform"
    key            = "management.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    assume_role = {
      role_arn = "arn:aws:iam::053562908965:role/service-role/terraform"
    }
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::053562908965:role/service-role/terraform"
  }

  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}

module "compliant_organization" {
  source = "../../modules/compliant-organization"
  providers = {
    aws = aws
  }

  organization_name = "ithought"
  admin_person_name = "ckdake"
}

module "compliant_account" {
  source = "../../modules/compliant-account"
  providers = {
    aws = aws
  }

  is_management_account = true

  administrator_role_arn      = aws_iam_role.administrator.arn
  management_kms_key_arn      = module.compliant_organization.management_kms_key_arn
  logs_destination_bucket_arn = module.compliant_organization.s3_logs_desination_bucket_arn
  aws_config_bucket_name      = module.compliant_organization.aws_config_bucket_name
}
