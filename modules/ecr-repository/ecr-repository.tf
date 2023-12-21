resource "aws_ecr_repository" "repository" {
  name                 = "${var.repository_namespace}/${var.repository_name}"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

# TODO(ckdake): replace principal * arn with arn of roles for running service
resource "aws_ecr_repository_policy" "repository_policy" {
  repository = aws_ecr_repository.repository.name
  policy     = <<EOF
{
"Version": "2008-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "AWS": [
        "arn:aws:iam::${local.account_id}:root"
      ]
    },
    "Action": [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  },
  {
    "Effect": "Allow",
    "Principal": {
      "AWS": [
        "arn:aws:iam::${local.account_id}:root"
      ]
    },
    "Action": [
      "ecr:BatchGetImage",
      "ecr:ListImages",
      "ecr:GetDownloadUrlForLayer"
    ]
  }
]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "repository" {
  repository = aws_ecr_repository.repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Always keep the most recent image",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["latest"],
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Always delete images older than 14 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "pull_artifacts" {
  name        = "ecr-pull-${var.repository_name}-artifacts"
  description = "allows pulling all the ${var.repository_name} artifacts"
  path        = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowPull",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:ListImages",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource" : [
          aws_ecr_repository.repository.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "push_artifacts" {
  name        = "ecr-push-${var.repository_name}-artifacts"
  description = "allows pushing all the ${var.repository_name} artifacts"
  path        = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowPushPull",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        "Resource" : [
          aws_ecr_repository.repository.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "use_ecr" {
  name        = "use-ecr"
  description = "allows a role to use ECR. requires repo permissions separately"
  path        = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GetAuthorizationToken",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}
