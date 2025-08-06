#!/bin/bash
# Deploy script for Linux/macOS
# This script deploys the infrastructure and application

set -e  # Exit on error

# Default values
AWS_REGION=${AWS_REGION:-"us-east-1"}
AWS_PROFILE=${AWS_PROFILE:-"default"}

echo "🚀 Starting deployment process..."

# Export AWS settings
export AWS_REGION
export AWS_PROFILE

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Failed to get AWS account ID. Check your AWS credentials."
    exit 1
fi
echo "AWS Account ID: $ACCOUNT_ID"

# Initialize Terraform
echo -e "\n📦 Initializing Terraform..."
cd terraform
terraform init

if [ $? -ne 0 ]; then
    echo "❌ Terraform init failed"
    exit 1
fi

# Plan Terraform changes
echo -e "\n📋 Planning Terraform changes..."
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    echo "❌ Terraform plan failed"
    exit 1
fi

# Apply Terraform changes
echo -e "\n🔨 Applying Terraform changes..."
if [ "${AUTO_APPROVE}" = "true" ]; then
    # Auto-approve for CI/CD
    terraform apply tfplan
else
    # Interactive mode
    read -p "Do you want to apply these changes? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        terraform apply tfplan
    else
        echo "Deployment cancelled."
        exit 0
    fi
fi

if [ $? -ne 0 ]; then
    echo "❌ Terraform apply failed"
    exit 1
fi

# Get outputs
ECR_URL=$(terraform output -raw ecr_repository_url)
ALB_DNS=$(terraform output -raw alb_dns_name)
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
SERVICE_NAME=$(terraform output -raw ecs_service_name)

# Build and push Docker image
echo -e "\n🐳 Building and pushing Docker image..."
cd ../app

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ECR_URL%/*}

# Build Docker image
docker build -t redis-ecs-demo .

# Tag and push image
docker tag redis-ecs-demo:latest "${ECR_URL}:latest"
docker push "${ECR_URL}:latest"

# Update ECS service to use new image
echo -e "\n🔄 Updating ECS service..."
aws ecs update-service \
    --cluster "$CLUSTER_NAME" \
    --service "$SERVICE_NAME" \
    --force-new-deployment \
    --region $AWS_REGION \
    --output json > /dev/null

echo -e "\n✅ Deployment complete!"
echo "Application URL: http://$ALB_DNS"
echo -e "\nNote: It may take a few minutes for the application to be fully available."

cd ..
