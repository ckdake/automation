resource "aws_iam_service_linked_role" "aws_service_role_for_config" {
  # The management account creates this already, so we don't need to try again
  count = var.is_management_account ? 0 : 1

  aws_service_name = "config.amazonaws.com"
}
