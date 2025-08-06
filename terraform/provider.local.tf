provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "elasticache-ecs-demo"
      Environment = "dev"
      ManagedBy   = "terraform"
      CostCenter  = "demo"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
