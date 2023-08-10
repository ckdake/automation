output "cluster_arn" {
  value = aws_ecs_cluster.ecs_cluster.arn
}

output "cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}
