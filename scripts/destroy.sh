#!/bin/bash
# Destroy script for Linux/macOS
# This script destroys all AWS resources created by Terraform

set -e  # Exit on error

# Default values
AWS_REGION=${AWS_REGION:-"us-east-1"}
AWS_PROFILE=${AWS_PROFILE:-"default"}

echo "🗑️ Starting resource destruction process..."

# Export AWS settings
export AWS_REGION
export AWS_PROFILE

# Confirm destruction
echo -e "\n⚠️  WARNING: This will destroy all resources created by Terraform!"
echo "This includes:"
echo "  - VPC and all networking components"
echo "  - ElastiCache Redis cluster"
echo "  - ECS cluster and services"
echo "  - Load balancer"
echo "  - ECR repository and images"

if [ "${AUTO_APPROVE}" = "true" ]; then
    # Auto-approve for CI/CD
    echo -e "\nAUTO_APPROVE is set. Proceeding with destruction..."
else
    # Interactive mode
    echo ""
    read -p "Are you sure you want to destroy all resources? Type 'destroy' to confirm: " confirm
    
    if [ "$confirm" != "destroy" ]; then
        echo "Destruction cancelled."
        exit 0
    fi
fi

# Change to terraform directory
cd terraform

# Destroy Terraform resources
echo -e "\n💣 Destroying Terraform resources..."
terraform destroy -auto-approve

if [ $? -ne 0 ]; then
    echo "❌ Terraform destroy failed"
    echo "Some resources may need manual cleanup in AWS Console"
    exit 1
fi

echo -e "\n✅ All resources have been destroyed!"
cd ..
