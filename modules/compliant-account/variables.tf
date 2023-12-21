variable "administrator_role_arn" {
  type        = string
  default     = ""
  description = "role allowed to create AWS support tickets"
}

variable "management_kms_key_arn" {
  type        = string
  default     = ""
  description = "ARN of the key to use for management purposes in this account, if blank, one will be created"
}

variable "logs_destination_bucket_arn" {
  type        = string
  description = "Target bucket for all AWS logs, except s3 access logs"
}

variable "aws_config_bucket_name" {
  type        = string
  description = "Name of the AWS config bucket"
}

variable "is_management_account" {
  type        = bool
  default     = false
  description = "True if this is the management account"
}
