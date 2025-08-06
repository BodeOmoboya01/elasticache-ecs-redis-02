# Destroy script for Windows PowerShell
# This script destroys all AWS resources created by Terraform

param(
    [Parameter(Mandatory=$false)]
    [string]$AwsRegion = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$AwsProfile = "default"
)

Write-Host "🗑️ Starting resource destruction process..." -ForegroundColor Red

# Set AWS credentials
$env:AWS_PROFILE = $AwsProfile
$env:AWS_REGION = $AwsRegion

# Confirm destruction
Write-Host "`n⚠️  WARNING: This will destroy all resources created by Terraform!" -ForegroundColor Yellow
Write-Host "This includes:" -ForegroundColor Yellow
Write-Host "  - VPC and all networking components" -ForegroundColor Yellow
Write-Host "  - ElastiCache Redis cluster" -ForegroundColor Yellow
Write-Host "  - ECS cluster and services" -ForegroundColor Yellow
Write-Host "  - Load balancer" -ForegroundColor Yellow
Write-Host "  - ECR repository and images" -ForegroundColor Yellow

$confirm = Read-Host "`nAre you sure you want to destroy all resources? Type 'destroy' to confirm"

if ($confirm -ne "destroy") {
    Write-Host "Destruction cancelled." -ForegroundColor Green
    exit 0
}

# Change to terraform directory
Set-Location -Path "terraform"

# Destroy Terraform resources
Write-Host "`n💣 Destroying Terraform resources..." -ForegroundColor Red
terraform destroy -auto-approve

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform destroy failed" -ForegroundColor Red
    Write-Host "Some resources may need manual cleanup in AWS Console" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ All resources have been destroyed!" -ForegroundColor Green
Set-Location -Path ".."
