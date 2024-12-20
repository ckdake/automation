variable "application" {
  type        = string
  description = "Name of the application, used as AWS tag"
}

variable "environment" {
  type        = string
  description = "Name of the environment, used as AWS tag"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket."
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "ID of KMS key to use. When blank, use an AWS managed key (some AWS services require this)."
}

variable "logging_bucket_name" {
  type        = string
  description = "Name of the bucket to use for logging access."
}

variable "additional_bucket_policy_statements" {
  type        = set(string)
  default     = []
  description = "Set of additional bucket policy statements to apply for this bucket"
}
