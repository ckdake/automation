variable "administrator_role_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "logs_destination_bucket_arn" {
  type        = string
  description = "Target bucket for all AWS logs, except s3 access logs"
}
