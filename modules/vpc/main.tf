terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"
    }
  }

  required_version = ">= 1.9.7"
}

data "aws_availability_zones" "available" {
  state = "available"
}
