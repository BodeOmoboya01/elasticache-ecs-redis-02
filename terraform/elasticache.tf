# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-redis-subnet-group"
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project_name}-redis-params"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name = "${var.project_name}-redis-params"
  }
}

# ElastiCache Redis Replication Group (Single Node with Encryption)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-redis"
  description          = "Redis cluster for ${var.project_name}"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_clusters   = 1 # Single node for cost savings
  parameter_group_name = aws_elasticache_parameter_group.main.name
  engine_version       = var.redis_engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.elasticache.id]

  # AWS Managed Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # Disabled for simplicity and cost

  # Maintenance window
  maintenance_window = "sun:05:00-sun:06:00"

  # Snapshot settings (disabled for cost savings)
  snapshot_retention_limit = 0

  tags = {
    Name = "${var.project_name}-redis"
  }
}

# ============================================================================
# SECONDARY ELASTICACHE CLUSTER WITH KMS ENCRYPTION
# ============================================================================

# Secondary ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "secondary" {
  name       = "${var.project_name}-redis-subnet-group-secondary"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-redis-subnet-group-secondary"
    Type = "KMS-Encrypted"
  }
}

# Secondary ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "secondary" {
  name   = "${var.project_name}-redis-params-secondary"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name = "${var.project_name}-redis-params-secondary"
    Type = "KMS-Encrypted"
  }
}

# Secondary ElastiCache Redis Replication Group (with Customer-Managed KMS Key)
resource "aws_elasticache_replication_group" "secondary" {
  replication_group_id = "${var.project_name}-redis-secondary"
  description          = "Secondary Redis cluster for ${var.project_name} with KMS encryption"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_clusters   = 1 # Single node for cost savings
  parameter_group_name = aws_elasticache_parameter_group.secondary.name
  engine_version       = var.redis_engine_version
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.secondary.name
  security_group_ids   = [aws_security_group.elasticache.id]

  # Customer-Managed KMS Encryption
  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.elasticache.arn
  transit_encryption_enabled = false # Disabled for simplicity and cost

  # Different maintenance window to avoid conflicts with main cluster
  maintenance_window = "sun:06:00-sun:07:00"

  # Snapshot settings (disabled for cost savings)
  snapshot_retention_limit = 0

  tags = {
    Name = "${var.project_name}-redis-secondary"
    Type = "KMS-Encrypted"
  }
}
