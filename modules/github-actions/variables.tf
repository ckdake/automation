variable "application" {
  type        = string
  description = "Name of the application, used as AWS tag"
}

variable "environment" {
  type        = string
  description = "Name of the environment, used as AWS tag"
}

variable "repository_names" {
  description = "list of ECR repositories github actions should have access to"
  type        = list(any)
  default     = []
}

variable "policy_attachment_arns" {
  description = "list of policies that should be attached to the github actions role"
  type        = list(any)
  default     = []
}
