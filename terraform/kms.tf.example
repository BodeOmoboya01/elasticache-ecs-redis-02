# Example KMS configuration for migrating to customer-managed keys
# Rename this file to kms.tf when ready to migrate

# KMS Key for ElastiCache encryption
resource "aws_kms_key" "elasticache" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project_name}-elasticache-kms"
  }
}

# KMS Key Alias
resource "aws_kms_alias" "elasticache" {
  name          = "alias/${var.project_name}-elasticache"
  target_key_id = aws_kms_key.elasticache.key_id
}

# KMS Key Policy
resource "aws_kms_key_policy" "elasticache" {
  key_id = aws_kms_key.elasticache.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow ElastiCache to use the key"
        Effect = "Allow"
        Principal = {
          Service = "elasticache.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "elasticache.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# To use this KMS key, update elasticache.tf:
# 1. Add: kms_key_id = aws_kms_key.elasticache.arn
# 2. Note: You'll need to create a new cluster as you can't change encryption on existing clusters
