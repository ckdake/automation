locals {
  sample_app_name = "sample-app"
}

module "sample_repository" {
  source = "../../modules/ecr-repository"
  providers = {
    aws = aws
  }

  repository_namespace = "ithought"
  repository_name      = local.sample_app_name
  kms_key_arn          = module.compliant_account.management_kms_key_arn
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

  vpc_name                    = "sample-vpc"
  vpc_cidr_prefix             = "10.0"
  logs_destination_bucket_arn = module.compliant_account.logs_destination_bucket_arn
}

module "sample_service" {
  source = "../../modules/ecs-service"
  providers = {
    aws = aws
  }

  desired_count = 0

  ecr_repository_image_url = module.sample_repository.repository_url
  image_tag                = "latest"
  ecs_cluster_id           = module.sample_cluster.cluster_id

  service_name       = local.sample_app_name
  pull_policy_arn    = module.sample_repository.pull_policy_arn
  use_ecr_policy_arn = module.sample_repository.use_ecr_policy_arn

  vpc_id                = module.sample_vpc.vpc_id
  public_network_acl_id = module.sample_vpc.public_network_acl_id
  public_subnets        = module.sample_vpc.public_subnet_ids
}


module "github_actions" {
  source = "../../modules/github-actions"
  providers = {
    aws = aws
  }

  repository_names = [
    "repo:ckdake/automation:*"
  ]
  policy_attachment_arns = [
    module.sample_repository.use_ecr_policy_arn,
    module.sample_repository.push_policy_arn
  ]
}
