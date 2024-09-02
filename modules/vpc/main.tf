terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65.0"
    }
  }

  required_version = ">= 1.8.5"
}

data "aws_availability_zones" "available" {
  state = "available"
}
