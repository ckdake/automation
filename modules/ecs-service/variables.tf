variable "application" {
  type        = string
  description = "Name of the application, used as AWS tag"
}

variable "environment" {
  type        = string
  description = "Name of the environment, used as AWS tag"
}

variable "desired_count" {
  type = string
}

variable "ecr_repository_image_url" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "public_subnets" {
  type = set(string)
}

variable "pull_policy_arn" {
  type = string
}

variable "use_ecr_policy_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_network_acl_id" {
  type = string
}
