# Script to configure CI/CD platform choice

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "ElastiCache ECS Redis - CI/CD Platform Selection" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This project supports both CircleCI and GitHub Actions."
Write-Host "You must choose ONE to avoid conflicts." -ForegroundColor Yellow
Write-Host ""
Write-Host "Which CI/CD platform would you like to use?"
Write-Host "1) CircleCI"
Write-Host "2) GitHub Actions"
Write-Host "3) None (manual deployment only)"
Write-Host ""
$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Configuring for CircleCI..." -ForegroundColor Green
        
        # Disable GitHub Actions
        if (Test-Path ".github\workflows\deploy.yml") {
            Move-Item -Path ".github\workflows\deploy.yml" -Destination ".github\workflows\deploy.yml.disabled" -Force
            Write-Host "✓ Disabled GitHub Actions workflow" -ForegroundColor Green
        }
        
        # Enable CircleCI
        if (Test-Path ".circleci\config.yml.disabled") {
            Move-Item -Path ".circleci\config.yml.disabled" -Destination ".circleci\config.yml" -Force
            Write-Host "✓ Enabled CircleCI configuration" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "CircleCI configuration complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Go to https://circleci.com and connect your repository"
        Write-Host "2. Add the following environment variables in CircleCI:"
        Write-Host "   - AWS_ACCESS_KEY_ID"
        Write-Host "   - AWS_SECRET_ACCESS_KEY"
        Write-Host "   - AWS_REGION"
        Write-Host "   - TF_STATE_BUCKET"
        Write-Host "   - ENVIRONMENT"
        Write-Host "3. See CIRCLECI_SETUP.md for detailed instructions"
    }
    "2" {
        Write-Host ""
        Write-Host "Configuring for GitHub Actions..." -ForegroundColor Green
        
        # Disable CircleCI
        if (Test-Path ".circleci\config.yml") {
            Move-Item -Path ".circleci\config.yml" -Destination ".circleci\config.yml.disabled" -Force
            Write-Host "✓ Disabled CircleCI configuration" -ForegroundColor Green
        }
        
        # Enable GitHub Actions
        if (Test-Path ".github\workflows\deploy.yml.disabled") {
            Move-Item -Path ".github\workflows\deploy.yml.disabled" -Destination ".github\workflows\deploy.yml" -Force
            Write-Host "✓ Enabled GitHub Actions workflow" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "GitHub Actions configuration complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Go to your GitHub repository settings"
        Write-Host "2. Navigate to Settings > Secrets and variables > Actions"
        Write-Host "3. Add the following secrets:"
        Write-Host "   - AWS_ACCESS_KEY_ID"
        Write-Host "   - AWS_SECRET_ACCESS_KEY"
        Write-Host "   - TF_STATE_BUCKET"
        Write-Host "4. Push to main or develop branch to trigger deployment"
    }
    "3" {
        Write-Host ""
        Write-Host "Configuring for manual deployment only..." -ForegroundColor Green
        
        # Disable both
        if (Test-Path ".circleci\config.yml") {
            Move-Item -Path ".circleci\config.yml" -Destination ".circleci\config.yml.disabled" -Force
            Write-Host "✓ Disabled CircleCI configuration" -ForegroundColor Green
        }
        if (Test-Path ".github\workflows\deploy.yml") {
            Move-Item -Path ".github\workflows\deploy.yml" -Destination ".github\workflows\deploy.yml.disabled" -Force
            Write-Host "✓ Disabled GitHub Actions workflow" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "CI/CD disabled. Use the scripts in the 'scripts' directory for manual deployment." -ForegroundColor Yellow
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Configuration complete! Remember to commit these changes:" -ForegroundColor Cyan
Write-Host "git add -A" -ForegroundColor Yellow
Write-Host "git commit -m 'Configure CI/CD platform'" -ForegroundColor Yellow
Write-Host ""
