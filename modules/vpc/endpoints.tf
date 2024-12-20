resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${local.aws_region}.s3"
  route_table_ids   = [aws_route_table.public.id]
  vpc_endpoint_type = "Gateway"

  policy = <<EOP
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
EOP

  tags = local.tags
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${local.aws_region}.dynamodb"
  route_table_ids   = [aws_route_table.public.id]
  vpc_endpoint_type = "Gateway"

  policy = <<EOP
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
EOP

  tags = local.tags
}
