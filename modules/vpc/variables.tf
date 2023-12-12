variable "vpc_cidr_prefix" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "logs_destination_bucket_arn" {
  type        = string
  description = "Target bucket for all AWS logs, except s3 access logs"
}
