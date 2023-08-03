terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

variable "bucket_name" {
    type = string
}

resource "aws_s3_bucket" "bucket" {
    bucket = var.bucket_name
}