resource "aws_iam_role" "aws_support_access" {
  name = "aws-support-access"
  path = "/person-role/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "AWS": "${var.administrator_role_arn}"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# See https://github.com/z0ph/MAMIP/blob/master/policies/AWSSupportAccess
resource "aws_iam_role_policy_attachment" "aws_support_access" {
  role       = aws_iam_role.aws_support_access.id
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}
