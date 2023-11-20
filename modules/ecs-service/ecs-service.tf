resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-ecs-security-group"
  description = "connectivity for the ${var.service_name} service"
}

resource "aws_vpc_security_group_egress_rule" "service_all_outbound_443" {
  security_group_id = aws_security_group.ecs_service.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "service_all_inbound_8080" {
  security_group_id = aws_security_group.ecs_service.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_cloudwatch_log_group" "service" {
  name              = var.service_name
  retention_in_days = 365
}

resource "aws_ecs_task_definition" "task" {
  family = var.service_name
  container_definitions = jsonencode([
    {
      name                   = var.service_name
      image                  = "${var.ecr_repository_image_url}:${var.image_tag}"
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
      portMappings           = []
      mountPoints = [
        {
          containerPath = "/var/lib/nginx/tmp"
          sourceVolume  = "nginx-tmp"
        },
        {
          containerPath = "/var/run"
          sourceVolume  = "nginx-run"
        },
        {
          containerPath = "/tmp"
          sourceVolume  = "tmp"
        }
      ]
      volumesFrom = []
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.service_name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  volume {
    name = "nginx-tmp"
  }

  volume {
    name = "nginx-run"
  }

  volume {
    name = "tmp"
  }
}

resource "aws_ecs_service" "service" {
  name                    = var.service_name
  cluster                 = var.ecs_cluster_id
  task_definition         = aws_ecs_task_definition.task.arn
  desired_count           = var.desired_count
  launch_type             = "FARGATE"
  scheduling_strategy     = "REPLICA"
  wait_for_steady_state   = false
  enable_ecs_managed_tags = false

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service.id]
    subnets          = var.public_subnets
  }

  # alternatively set public ip to private, and use an alb to get traffic in
  # load_balancer {
  #   target_group_arn = aws_alb_target_group.portal_web_target_group.arn
  #   container_name   = "sample-app-web"
  #   container_port   = 3000
  # }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    aws_iam_role_policy.task_execution_role
  ]
}
