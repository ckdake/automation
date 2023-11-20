resource "aws_network_acl_rule" "outbound_443" {
  # Allows outbound 443 for ECR pull, TODO: limit to private endpoint
  network_acl_id = var.public_network_acl_id
  rule_number    = 301
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "inbound_8080" {
  # Allows inbound 8080 for web, TODO: limit target to ecs cluster
  network_acl_id = var.public_network_acl_id
  rule_number    = 302
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 8080
  to_port        = 8080
}
