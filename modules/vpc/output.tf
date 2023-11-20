output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_network_acl_id" {
  value = aws_network_acl.public.id
}
