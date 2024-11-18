terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
  }

  required_version = ">= 1.9.7"
}

data "aws_availability_zones" "available" {
  state = "available"
}
