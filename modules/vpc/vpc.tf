resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_prefix}.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_default_security_group" "vpc" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "vpc" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}


