resource "aws_iam_service_linked_role" "aws_service_role_for_config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "aws_config" {
  name     = "aws-config"
  role_arn = aws_iam_service_linked_role.aws_service_role_for_config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "aws_config" {
  name           = "aws-config"
  s3_bucket_name = var.aws_config_bucket_name

  depends_on = [aws_config_configuration_recorder.aws_config]
}

resource "aws_config_configuration_recorder_status" "aws_config" {
  name       = aws_config_configuration_recorder.aws_config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.aws_config]
}
