output "pull_policy_arn" {
  value = aws_iam_policy.pull_artifacts.arn
}

output "push_policy_arn" {
  value = aws_iam_policy.push_artifacts.arn
}

output "repository_arn" {
  value = aws_ecr_repository.repository.arn
}

output "use_ecr_policy_arn" {
  value = aws_iam_policy.use_ecr.arn
}
