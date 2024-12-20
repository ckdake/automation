variable "application" {
  type        = string
  description = "Name of the application, used as AWS tag"
}

variable "environment" {
  type        = string
  description = "Name of the environment, used as AWS tag"
}

variable "organization_name" {
  type        = string
  description = "The name of the organization, used in S3 bucket names and other spots"
}
