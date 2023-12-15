data "aws_iam_policy_document" "assume_sns_delivery_status_to_cloudwatch" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "sns_delivery_status_to_cloudwatch" {
  name = "sns-delivery-status-to-cloudwatch"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume_sns_delivery_status_to_cloudwatch.json
}
