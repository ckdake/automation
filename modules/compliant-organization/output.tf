output "root_organization_id" {
  value       = aws_organizations_organization.root.id
  description = "ID of the root organization"
}

output "management_kms_key_arn" {
  value       = aws_kms_key.management.arn
  description = "ARN of the management KMS key"
}

output "s3_logs_desination_bucket_arn" {
  value       = module.aws_logs.arn
  description = "ARN of the bucket to use for S3 access logs"
}

output "aws_config_bucket_name" {
  value       = local.aws_config_bucket_name
  description = "Name of the bucket to use for AWS Config"
}
