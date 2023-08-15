module "sample_repository" {
  source = "../../modules/ecr-repository"
  providers = {
    aws = aws
  }

  repository_namespace = "ithought"
  repository_name      = "sample-app"
  kms_key_arn          = aws_kms_key.management.arn
}

module "sample_cluster" {
  source = "../../modules/ecs-cluster"
  providers = {
    aws = aws
  }

  cluster_name = "sample-cluster"
}

module "sample_vpc" {
  source = "../../modules/vpc"
  providers = {
    aws = aws
  }

  vpc_name        = "sample-vpc"
  vpc_cidr_prefix = "10.0"
}

module "sample_service" {
  source = "../../modules/ecs-service"
  providers = {
    aws = aws
  }

  ecr_artifact   = module.sample_repository.repository_arn
  ecs_cluster_id = module.sample_cluster.cluster_id

  service_name       = "sample-app"
  pull_policy_arn    = module.sample_repository.pull_policy_arn
  use_ecr_policy_arn = module.sample_repository.use_ecr_policy_arn

  vpc_id  = module.sample_vpc.vpc_id
  subnets = module.sample_vpc.public_subnet_ids
}


module "github_actions" {
  source = "../../modules/github-actions"
  providers = {
    aws = aws
  }

  repository_names = [
    "repo:ithought/sample-app-web:*"
  ]
  policy_attachment_arns = [
    module.sample_repository.use_ecr_policy_arn
  ]
}

resource "aws_iam_role_policy_attachment" "github_actions_push_to_ecr" {
  role       = module.github_actions.role_name
  policy_arn = module.sample_repository.push_policy_arn
}
