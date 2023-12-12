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
    role_arn       = "arn:aws:iam::053562908965:role/administrator"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::053562908965:role/administrator"
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

  administrator_role_arn = aws_iam_role.administrator.arn
  kms_key_arn            = aws_kms_key.management.arn
}
