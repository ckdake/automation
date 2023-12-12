# Manage the default resources, and ensure they are appropriately locked down

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

resource "aws_flow_log" "default" {
  log_destination      = var.logs_destination_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_default_vpc.default.id
}

# Empty security group disables all ingress and egress traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
}

# Empty route table disables default routes 
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_default_vpc.default.default_route_table_id
}

# Empty ACL blocks all traffic on default vpc acl
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_default_vpc.default.default_network_acl_id
  tags = {
    Name = "default-vpc-default-acl"
  }

  subnet_ids = [
    for default_subnet in aws_default_subnet.default_subnet : default_subnet.id
  ]
}

# Disable default addressing in default subnets, and name them
# there are 6 azs in us-east-1. other zones have less!
resource "aws_default_subnet" "default_subnet" {
  count = 6

  availability_zone       = element(data.aws_availability_zones.available.names[*], count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "default-subnet"
  }
}

resource "aws_ebs_default_kms_key" "aws_ebs_default_kms_key" {
  key_arn = var.kms_key_arn
}

resource "aws_ebs_encryption_by_default" "aws_ebs_encryption_by_default" {
  enabled = true
}
