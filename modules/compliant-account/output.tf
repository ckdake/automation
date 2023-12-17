output "logs_destination_bucket_arn" {
  value       = var.logs_destination_bucket_arn
  description = "Target bucket for all AWS logs, except s3 access logs."
}

output "management_kms_key_arn" {
  value       = local.confirmed_management_kms_key_arn
  description = "KMS management key arn."
}
