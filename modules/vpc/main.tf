terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10.0"
    }
  }

  required_version = ">= 1.12.2"
}

data "aws_availability_zones" "available" {
  state = "available"
}
