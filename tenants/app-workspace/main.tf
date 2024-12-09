terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }

  required_version = ">= 1.9.7"

  backend "s3" {
    bucket         = "ithought-terraform"
    key            = "app-workspace.tfstate"
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

module "regional_config_data" {
  source = "../../modules/regional-config-data"

  providers = {
    aws = aws
  }
}
