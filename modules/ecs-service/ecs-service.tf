resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-ecs-security-group"
  description = "connectivity for the ${var.service_name} service"
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.service_name
  container_definitions    = var.container_definitions
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}
