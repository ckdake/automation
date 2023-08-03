terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket = "ithought-terraform"
    key = "management.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}