terraform {
  backend "s3" {
    bucket         = "elasticache-ecs-terraform-state-02"
    key            = "elasticache-ecs-redis/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "elasticache-ecs-terraform-locks"
  }
}
