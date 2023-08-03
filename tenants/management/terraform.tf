module "terraform_state_bucket" {
    source = "../../modules/s3-bucket"
    bucket_name = "ithought-terraform"
    logging_bucket_name = module.terraform_logging_bucket.id
    kms_key_arn = aws_kms_key.management.arn
}