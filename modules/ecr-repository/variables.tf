variable "application" {
  type        = string
  description = "Name of the application, used as AWS tag"
}

variable "environment" {
  type        = string
  description = "Name of the environment, used as AWS tag"
}

variable "kms_key_arn" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "repository_namespace" {
  type = string
}
