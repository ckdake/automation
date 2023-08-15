output "role_arn" {
  description = "role ARN for github-actions role"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "role name for github-actions role"
  value       = aws_iam_role.github_actions.name
}
