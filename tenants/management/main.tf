terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }

  required_version = ">= 1.10.3"

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

provider "aws" {
  region = "us-west-2"
  alias  = "secondary"

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
  aws_config_bucket_name      = module.compliant_organization.aws_config_bucket_name
}

module "global_config" {
  # This module sets up configuraiton for all things that are global in AWS
  # It should include things like IAM roles, route53 domains, etc. G
  source = "../../modules/global-config"

  providers = {
    aws = aws
  }
}

module "regional_config_primary" {
  # This module sets up configuration for eveyrthing region specific in AWS
  # It should include things like logging target buckets, KMS keys, etc
  source = "../../modules/regional-config"

  providers = {
    aws = aws
  }
}

module "regional_config_secondary" {
  # This module sets up configuration for eveyrthing region specific in AWS
  # It should include things like logging target buckets, KMS keys, etc
  source = "../../modules/regional-config"

  providers = {
    aws = aws.secondary
  }
}

module "regional_config_data" {
  # This module exposes config, for the region it's running in. This includes
  # global and regional specific config.
  source = "../../modules/regional-config-data"

  providers = {
    aws = aws
  }
}
