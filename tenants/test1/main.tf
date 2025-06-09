terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99.1"
    }
  }

  required_version = ">= 1.10.3"

  backend "s3" {
    bucket         = "ithought-terraform"
    key            = "test1.tfstate"
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
    role_arn = "arn:aws:iam::618006054620:role/service-role/terraform"
  }

  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}

module "regional_config_data" {
  source = "../../modules/regional-config-data"

  providers = {
    aws = aws
  }
}

module "compliant_account" {
  source = "../../modules/compliant-account"

  providers = {
    aws = aws
  }

  application = local.application
  environment = local.environment

  logs_destination_bucket_arn = module.regional_config_data.logs_destination_bucket_arn
  aws_config_bucket_name      = module.regional_config_data.aws_config_bucket_name
}
