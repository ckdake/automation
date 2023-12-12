terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }

  required_version = ">= 1.6.5"
}

data "aws_availability_zones" "available" {
  state = "available"
}
