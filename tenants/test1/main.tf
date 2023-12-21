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
    key            = "test1.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    role_arn       = "arn:aws:iam::053562908965:role/service-role/terraform"
    encrypt        = true
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

module "compliant_account" {
  source = "../../modules/compliant-account"
  providers = {
    aws = aws
  }

  logs_destination_bucket_arn = "arn:aws:s3:::ithought-aws-logs"
  aws_config_bucket_name      = "ithought-aws-config"
}

import {
  to = module.compliant_account.aws_iam_role.terraform
  id = "terraform"
}

import {
  to = module.compliant_account.aws_iam_role_policy_attachment.terraform_gets_administrator
  id = "terraform/arn:aws:iam::aws:policy/AdministratorAccess"
}
