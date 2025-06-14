terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99.1"
    }
  }

  required_version = ">= 1.10.3"
}

data "aws_availability_zones" "available" {
  state = "available"
}
