module "terraform_state_bucket" {
    source = "../../modules/s3-bucket"
    bucket_name = "ithought-terraform"
}