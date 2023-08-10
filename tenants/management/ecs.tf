module "sample_repository" {
  source = "../../modules/ecr-repository"

  repository_namespace = "ithought"
  repository_name      = "sample-app"
  kms_key_arn          = aws_kms_key.management.arn
}

module "sample_cluster" {
  source = "../../modules/ecs-cluster"

  cluster_name = "sample-cluster"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "sample-vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "sample_service" {
  source = "../../modules/ecs-service"

  service_name = "sample-app"
  vpc_id       = module.vpc.vpc_id
}
