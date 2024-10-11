data "terraform_remote_state" "self" {
  backend = "s3"

  workspace = terraform.workspace

  config = {
    bucket         = "ithought-terraform"
    key            = "app-workspace.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    assume_role = {
      role_arn = "arn:aws:iam::053562908965:role/service-role/terraform"
    }
    encrypt = true
  }
}
