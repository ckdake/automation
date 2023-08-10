resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-ecs-security-group"
  description = "connectivity for the ${var.service_name} service"
}
