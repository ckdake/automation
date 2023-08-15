variable "desired_count" {
  type = string
}

variable "ecr_artifact" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "subnets" {
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
