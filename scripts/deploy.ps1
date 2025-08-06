# Deploy script for Windows PowerShell
# This script deploys the infrastructure and application

param(
    [Parameter(Mandatory=$false)]
    [string]$AwsRegion = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$AwsProfile = "default"
)

Write-Host "🚀 Starting deployment process..." -ForegroundColor Green

# Set AWS credentials
$env:AWS_PROFILE = $AwsProfile
$env:AWS_REGION = $AwsRegion

# Get AWS account ID
try {
    $accountId = aws sts get-caller-identity --query Account --output text
    Write-Host "AWS Account ID: $accountId" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Failed to get AWS account ID. Check your AWS credentials." -ForegroundColor Red
    exit 1
}

# Initialize Terraform
Write-Host "`n📦 Initializing Terraform..." -ForegroundColor Cyan
Set-Location -Path "terraform"
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform init failed" -ForegroundColor Red
    exit 1
}

# Plan Terraform changes
Write-Host "`n📋 Planning Terraform changes..." -ForegroundColor Cyan
terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed" -ForegroundColor Red
    exit 1
}

# Apply Terraform changes
Write-Host "`n🔨 Applying Terraform changes..." -ForegroundColor Cyan
$confirm = Read-Host "Do you want to apply these changes? (yes/no)"
if ($confirm -eq "yes") {
    terraform apply tfplan
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Terraform apply failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Get outputs
$ecrUrl = terraform output -raw ecr_repository_url
$albDns = terraform output -raw alb_dns_name

# Build and push Docker image
Write-Host "`n🐳 Building and pushing Docker image..." -ForegroundColor Cyan
Set-Location -Path "../app"

# Login to ECR
aws ecr get-login-password --region $AwsRegion | docker login --username AWS --password-stdin $ecrUrl.Split("/")[0]

# Build Docker image
docker build -t redis-ecs-demo .

# Tag and push image
docker tag redis-ecs-demo:latest "${ecrUrl}:latest"
docker push "${ecrUrl}:latest"

# Update ECS service to use new image
Write-Host "`n🔄 Updating ECS service..." -ForegroundColor Cyan
aws ecs update-service `
    --cluster redis-ecs-demo-cluster `
    --service redis-ecs-demo-service `
    --force-new-deployment `
    --region $AwsRegion

Write-Host "`n✅ Deployment complete!" -ForegroundColor Green
Write-Host "Application URL: http://$albDns" -ForegroundColor Yellow
Write-Host "`nNote: It may take a few minutes for the application to be fully available." -ForegroundColor Cyan

Set-Location -Path ".."
