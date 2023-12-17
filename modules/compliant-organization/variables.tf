variable "organization_name" {
  type        = string
  description = "The name of the organization, used in S3 bucket names and other spots"
}

variable "admin_person_name" {
  type        = string
  description = "The name of a user to be allowed to perform admin things."
}
