terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }

  required_version = ">= 1.6.5"

  backend "s3" {
    bucket         = "ithought-terraform"
    key            = "management.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    role_arn       = "arn:aws:iam::053562908965:role/service-role/terraform"
    encrypt        = true
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
}

module "compliant_account" {
  source = "../../modules/compliant-account"
  providers = {
    aws = aws
  }

  administrator_role_arn      = aws_iam_role.administrator.arn
  management_kms_key_arn      = module.compliant_organization.management_kms_key_arn
  logs_destination_bucket_arn = module.compliant_organization.s3_logs_desination_bucket_arn
}
