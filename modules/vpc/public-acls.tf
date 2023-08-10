resource "aws_default_network_acl" "vpc" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  tags = {
    Name = "tenant-vpc-default-acl"
  }
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-subnet-acl"
  }
}

resource "aws_network_acl_rule" "public_inbound_100" {
  # Allows inbound from this VPC
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = aws_vpc.vpc.cidr_block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_inbound_101" {
  # Blocks rdp
  network_acl_id = aws_network_acl.public.id
  rule_number    = 101
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}

resource "aws_network_acl_rule" "public_inbound_102" {
  # Allows tcp returns
  network_acl_id = aws_network_acl.public.id
  rule_number    = 102
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_outbound_200" {
  # Allows outbound to this VPC
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = aws_vpc.vpc.cidr_block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_outbound_201" {
  # Block rdp
  network_acl_id = aws_network_acl.public.id
  rule_number    = 203
  egress         = true
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
}

resource "aws_network_acl_rule" "public_outbound_202" {
  # Allows tcp returns
  network_acl_id = aws_network_acl.public.id
  rule_number    = 204
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
