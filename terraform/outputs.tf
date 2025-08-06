output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "Redis cluster port"
  value       = aws_elasticache_replication_group.main.port
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "nat_instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "nat_instance_public_ip" {
  description = "Public IP of the NAT instance"
  value       = aws_eip.nat_instance.public_ip
}

output "estimated_monthly_cost" {
  description = "Rough estimate of monthly AWS costs"
  value       = <<-EOT
    Estimated Monthly Costs (USD):
    - NAT Instance (t3.nano): ~$3.80
    - ElastiCache (t3.micro): ~$13
    - ALB: ~$16 + data transfer
    - ECS Fargate Spot: ~$3-5
    - CloudWatch Logs: ~$1
    - Total: ~$37-39/month
    
    Cost Savings:
    - Using NAT Instance instead of NAT Gateway saves ~$41/month!
    - Total infrastructure cost reduced by ~54%
    
    Further Cost Optimization Tips:
    - Use Lambda instead of ECS for lighter workloads
    - Consider using ElastiCache Serverless for variable workloads
    - Use S3 endpoints to reduce NAT instance data transfer costs
  EOT
}
