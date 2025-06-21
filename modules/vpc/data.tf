locals {
  aws_region = data.aws_region.current.region
}

data "aws_region" "current" {}
