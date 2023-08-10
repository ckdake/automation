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

module "sample_vpc" {
  source = "../../modules/vpc"

  vpc_name = "sample-vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "sample_service" {
  source = "../../modules/ecs-service"

  container_definitions = jsonencode([
    {
      name                   = "sample-app"
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

  ecr_artifact    = module.sample_repository.repository_arn
  ecs_cluster_arn = module.sample_cluster.cluster_arn

  service_name       = "sample-app"
  pull_policy_arn    = module.sample_repository.pull_policy_arn
  use_ecr_policy_arn = module.sample_repository.use_ecr_policy_arn

  vpc_id  = module.sample_vpc.vpc_id
  subnets = module.sample_vpc.public_subnet_ips
}
