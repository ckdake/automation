resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-ecs-security-group"
  description = "connectivity for the ${var.service_name} service"
}

resource "aws_ecs_task_definition" "task" {
  family = var.service_name
  container_definitions = jsonencode([
    {
      name                   = var.service_name
      image                  = "latest"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
      portMappings           = []
      mountPoints            = []
      volumesFrom            = []
    }
  ])
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "service" {
  name                = var.service_name
  cluster             = var.ecs_cluster_arn
  task_definition     = aws_iam_role.task_role.arn
  desired_count       = 0
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_service.id]
    subnets          = var.subnets
  }

  # TODO(ckdake) setup ALBs
  # load_balancer {
  #   target_group_arn = aws_alb_target_group.portal_web_target_group.arn
  #   container_name   = "sample-app-web"
  #   container_port   = 3000
  # }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}
