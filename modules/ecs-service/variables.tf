variable "container_definitions" {
  type = string
}

variable "ecr_artifact" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "service_name" {
  type = string
}

variable "subnets" {
  type = string
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
