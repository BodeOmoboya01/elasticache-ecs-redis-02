# CI Provider Configuration
provider "aws" {
  region = var.aws_region
  # No profile specified, will use environment variables:
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}
