terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }

  required_version = ">= 1.10.3"
}

data "aws_availability_zones" "available" {
  state = "available"
}
