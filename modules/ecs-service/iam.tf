data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${var.service_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.service_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role_gets_use_ecr" {
  role       = aws_iam_role.task_execution_role.id
  policy_arn = var.use_ecr_policy_arn
}

resource "aws_iam_role_policy_attachment" "task_execution_role_gets_pull_artifacts" {
  role       = aws_iam_role.task_execution_role.id
  policy_arn = var.pull_policy_arn
}

data "aws_iam_policy" "task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "task_execution_role" {
  role   = aws_iam_role.task_execution_role.id
  name   = "AmazonECSTaskExecutionRolePolicy"
  policy = data.aws_iam_policy.task_execution_role.policy
}
