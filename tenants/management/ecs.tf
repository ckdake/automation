module "sample-repository" {
  source = "../../modules/ecr-repository"

  repository_namespace = "ithought"
  repository_name      = "sample-app"
  kms_key_arn          = aws_kms_key.management.arn
}

module "sample-cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = "sample-cluster"
}
