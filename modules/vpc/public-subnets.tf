resource "aws_subnet" "public" {
  count = 6 # us-east-1 lets us have 6. why not.

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.vpc_cidr_prefix}.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "public-subnet"
  }

  timeouts {
    delete = "60s"
  }
}

resource "aws_network_acl_association" "public" {
  count = length(aws_subnet.public)

  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public[count.index].id
}
