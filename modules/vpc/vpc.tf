resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

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

resource "aws_default_network_acl" "vpc" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  tags = {
    Name = "tenant-vpc-default-acl"
  }
}
