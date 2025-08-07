# ElastiCache ECS Redis Infrastructure

A cost-optimized AWS infrastructure project demonstrating Redis integration with ECS Fargate, featuring migration from AWS-managed to customer-managed KMS encryption for ElastiCache.

## 🏗️ Architecture Overview

This project deploys a complete AWS infrastructure stack with:

- **ECS Fargate Spot**: Containerized Node.js application with auto-scaling
- **ElastiCache Redis**: Dual cluster setup for KMS migration (main + secondary)
- **Application Load Balancer**: Public-facing ALB for traffic distribution
- **VPC with NAT Instance**: Cost-optimized networking (saves ~$41/month vs NAT Gateway)
- **KMS Encryption**: Customer-managed keys for enhanced security
- **ECR**: Container registry for Docker images

### Architecture Diagram

```text
Internet → ALB → ECS Fargate (Spot) → ElastiCache Redis
                     ↓
                NAT Instance → Internet (for outbound)
```

## 💰 Cost Optimization

**Estimated Monthly Costs (USD):**

- NAT Instance (t3.nano): ~$3.80
- ElastiCache (t3.micro): ~$13 per cluster
- ALB: ~$16 + data transfer
- ECS Fargate Spot: ~$3-5
- CloudWatch Logs: ~$1
- KMS Key: ~$1
- **Total**: ~$38-40/month (single cluster) or ~$51-53/month (during migration)

**Cost Savings Implemented:**

- ✅ NAT Instance instead of NAT Gateway (saves ~$41/month)
- ✅ Fargate Spot for ECS tasks (70% discount)
- ✅ Single-node Redis clusters (no replicas)
- ✅ Minimal log retention (7 days)
- ✅ t3.micro/nano instances (smallest available)

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Docker installed locally
- Node.js 18+ (for local development)

### Local Development Setup

1. **Clone the repository:**

```bash
git clone https://github.com/BodeOmoboya01/elasticache-ecs-redis-02.git
cd elasticache-ecs-redis-02
```

2. **Configure Terraform backend:**

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

3. **Initialize Terraform:**

```bash
terraform init
```

4. **Deploy infrastructure:**

```bash
# Review the plan
terraform plan

# Apply changes
terraform apply
```

5. **Build and deploy application:**

```bash
cd ../scripts
./deploy.sh  # Linux/macOS
# or
./deploy.ps1  # Windows PowerShell
```

## 📁 Project Structure

```tree
.
├── app/                    # Node.js application
│   ├── server.js          # Express server with Redis integration
│   ├── package.json       # Node dependencies
│   └── Dockerfile         # Container configuration
├── terraform/             # Infrastructure as Code
│   ├── vpc.tf            # Network configuration
│   ├── elasticache.tf    # Redis clusters (main + secondary)
│   ├── kms.tf            # Customer-managed KMS keys
│   ├── ecs.tf            # ECS cluster and services
│   ├── alb.tf            # Load balancer configuration
│   ├── nat_instance.tf   # Cost-optimized NAT
│   └── outputs.tf        # Terraform outputs
└── scripts/              # Deployment automation
    ├── deploy.sh         # Linux/macOS deployment
    └── deploy.ps1        # Windows deployment
```

## 🔄 ElastiCache KMS Migration

The infrastructure supports zero-downtime migration from AWS-managed to customer-managed KMS encryption.

### Current Setup

**Main Cluster** (`redis-ecs-demo-02-redis`):

- AWS-managed encryption
- Currently serving production traffic

**Secondary Cluster** (`redis-ecs-demo-02-redis-secondary`):

- Customer-managed KMS encryption
- Ready for migration

### Migration Steps

1. **Verify both clusters are running:**

```bash
terraform output redis_endpoint          # Main cluster
terraform output redis_secondary_endpoint # Secondary cluster
```

2. **Test secondary cluster connectivity:**

```bash
# Update ECS task definition temporarily to test
aws ecs update-service \
  --cluster redis-ecs-demo-02-cluster \
  --service redis-ecs-demo-02-service \
  --task-definition <new-task-def-with-secondary-endpoint>
```

3. **Migrate data (choose one method):**

**Option A: Redis MIGRATE (for small datasets):**

```bash
redis-cli -h <main-endpoint> --scan | \
  redis-cli -h <secondary-endpoint> --pipe
```

**Option B: Backup and Restore:**

```bash
# Create snapshot from main cluster
aws elasticache create-snapshot \
  --replication-group-id redis-ecs-demo-02-redis \
  --snapshot-name migration-snapshot

# Restore to secondary (requires cluster recreation)
```

**Option C: Application-level dual writes:**

- Modify application to write to both clusters
- Gradually shift reads to secondary

4. **Switch traffic to secondary cluster:**

```bash
# Update ECS task environment variable
# REDIS_HOST = secondary cluster endpoint
terraform apply -var="redis_endpoint_override=<secondary-endpoint>"
```

5. **Decommission main cluster:**

```bash
# After verification, remove main cluster from elasticache.tf
# Keep only the secondary cluster configuration
terraform apply
```

## 🔧 Configuration

### Environment Variables

The application uses these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_HOST` | Redis cluster endpoint | `localhost` |
| `REDIS_PORT` | Redis port | `6379` |
| `NODE_ENV` | Environment mode | `production` |
| `PORT` | Application port | `3000` |

### Terraform Variables

Key variables in `terraform/variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS deployment region | `us-east-1` |
| `project_name` | Resource naming prefix | `redis-ecs-demo-02` |
| `redis_node_type` | ElastiCache instance type | `cache.t3.micro` |
| `ecs_task_cpu` | ECS task CPU units | `256` |
| `ecs_task_memory` | ECS task memory (MB) | `512` |
| `use_fargate_spot` | Enable Spot instances | `true` |

## 📊 Application Features

The Node.js application demonstrates:

- **Visitor Counter**: Increments on each page load using Redis INCR
- **Health Check**: `/health` endpoint for ALB health checks
- **Statistics**: `/stats` endpoint showing Redis metrics
- **Reset Function**: POST to `/reset` to clear counter

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Main page with visitor counter |
| `/health` | GET | Health check for ALB |
| `/stats` | GET | Redis statistics and metrics |
| `/reset` | POST | Reset visitor counter |

## 🔐 Security Features

- **KMS Encryption**: Customer-managed keys for ElastiCache at-rest encryption
- **VPC Isolation**: Private subnets for ECS and ElastiCache
- **Security Groups**: Restrictive ingress rules
- **IAM Roles**: Least-privilege access for ECS tasks
- **No SSH Access**: NAT instance configured without SSH by default

## 🛠️ Maintenance

### Monitoring

Check cluster health:

```bash
# View ElastiCache metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ElastiCache \
  --metric-name CPUUtilization \
  --dimensions Name=CacheClusterId,Value=redis-ecs-demo-02-redis-001 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### Backup Strategy

While snapshots are disabled for cost savings, you can enable them:

```hcl
# In elasticache.tf, modify:
snapshot_retention_limit = 1  # Days to retain
snapshot_window = "03:00-04:00"  # UTC
```

### Scaling

To scale the infrastructure:

1. **ECS Tasks:**

```bash
terraform apply -var="ecs_desired_count=3"
```

2. **Redis Node Type:**

```bash
terraform apply -var="redis_node_type=cache.t3.small"
```

## 🧹 Cleanup

To destroy all resources:

```bash
cd scripts
./destroy.sh  # Linux/macOS
# or
./destroy.ps1  # Windows PowerShell
```

Or manually:

```bash
cd terraform
terraform destroy
```

## 📝 Important Notes

1. **ElastiCache Encryption**: Cannot be changed on existing clusters - requires cluster recreation
2. **KMS Key Deletion**: Has a 7-day minimum waiting period
3. **NAT Instance**: Ensure it's running for ECS tasks to pull images
4. **Costs**: Monitor AWS Cost Explorer for actual charges

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is for demonstration purposes. Adjust security and scaling settings for production use.

## 🆘 Troubleshooting

### Common Issues

**ECS tasks failing to start:**

- Check NAT instance is running
- Verify ECR repository has images
- Review CloudWatch logs in `/ecs/redis-ecs-demo-02`

**Redis connection errors:**

- Verify security group rules
- Check ElastiCache cluster status
- Ensure ECS tasks are in private subnets

**Terraform state issues:**

- Ensure S3 backend bucket exists
- Check AWS credentials
- Verify DynamoDB lock table

## 📚 Additional Resources

- [AWS ElastiCache Documentation](https://docs.aws.amazon.com/elasticache/)
- [ECS Fargate Spot Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-capacity-providers.html)
- [KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [Redis Commands Reference](https://redis.io/commands)

## 📧 Contact

For questions or issues, please open a GitHub issue in this repository.
