data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_iam_role" "databricks" {
  name = "${var.name_prefix}-databricks"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_instance_profile" "databricks" {
  name = "${var.name_prefix}-databricks"
  role = aws_iam_role.databricks.name
}

resource "aws_iam_role_policy" "databricks_s3" {
  name = "${var.name_prefix}-databricks-s3"
  role = aws_iam_role.databricks.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_bucket_arn,
          "${var.raw_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.curated_bucket_arn,
          "${var.curated_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

resource "aws_iam_role" "cicd" {
  name = "${var.name_prefix}-cicd"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.cicd_principal_arns
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "cicd_minimal" {
  name = "${var.name_prefix}-cicd-minimal"
  role = aws_iam_role.cicd.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketEncryption",
          "s3:PutBucketVersioning",
          "s3:PutLifecycleConfiguration",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_bucket_arn,
          var.curated_bucket_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:CreateAlias",
          "kms:TagResource",
          "kms:PutKeyPolicy",
          "kms:EnableKeyRotation",
          "kms:ScheduleKeyDeletion",
          "kms:DescribeKey",
          "kms:ListAliases"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetRole"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-databricks",
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-cicd",
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.name_prefix}-databricks"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "budgets:CreateBudget",
          "budgets:UpdateBudget",
          "budgets:DeleteBudget",
          "budgets:DescribeBudget",
          "budgets:ListBudgets"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:budgets::${data.aws_caller_identity.current.account_id}:budget/${var.name_prefix}-monthly"
      },
      {
        Effect = "Allow"
        Action = [
          "config:PutConfigurationRecorder",
          "config:PutDeliveryChannel",
          "config:StartConfigurationRecorder",
          "config:StopConfigurationRecorder",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:PutConfigRule",
          "config:DeleteConfigRule",
          "config:DescribeConfigRules",
          "config:DescribeConfigurationRecorders",
          "config:DescribeDeliveryChannels"
        ]
        Resource = "*"
      }
    ]
  })
}
