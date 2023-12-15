variable "administrator_role_arn" {
  type        = string
  default     = "*"
  description = "role allowed to create AWS support tickets"
}

variable "management_kms_key_arn" {
  type        = string
  description = "ARN of the key to use for management purposes in this account"
}

variable "logs_destination_bucket_arn" {
  type        = string
  description = "Target bucket for all AWS logs, except s3 access logs"
}
