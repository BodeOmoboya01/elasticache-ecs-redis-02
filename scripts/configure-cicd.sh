#!/bin/bash
# Script to configure CI/CD platform choice

echo "================================================"
echo "ElastiCache ECS Redis - CI/CD Platform Selection"
echo "================================================"
echo ""
echo "This project supports both CircleCI and GitHub Actions."
echo "You must choose ONE to avoid conflicts."
echo ""
echo "Which CI/CD platform would you like to use?"
echo "1) CircleCI"
echo "2) GitHub Actions"
echo "3) None (manual deployment only)"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Configuring for CircleCI..."
        # Disable GitHub Actions
        if [ -f ".github/workflows/deploy.yml" ]; then
            mv .github/workflows/deploy.yml .github/workflows/deploy.yml.disabled
            echo "✓ Disabled GitHub Actions workflow"
        fi
        # Enable CircleCI
        if [ -f ".circleci/config.yml.disabled" ]; then
            mv .circleci/config.yml.disabled .circleci/config.yml
            echo "✓ Enabled CircleCI configuration"
        fi
        echo ""
        echo "CircleCI configuration complete!"
        echo ""
        echo "Next steps:"
        echo "1. Go to https://circleci.com and connect your repository"
        echo "2. Add the following environment variables in CircleCI:"
        echo "   - AWS_ACCESS_KEY_ID"
        echo "   - AWS_SECRET_ACCESS_KEY" 
        echo "   - AWS_REGION"
        echo "   - TF_STATE_BUCKET"
        echo "   - ENVIRONMENT"
        echo "3. See CIRCLECI_SETUP.md for detailed instructions"
        ;;
    2)
        echo ""
        echo "Configuring for GitHub Actions..."
        # Disable CircleCI
        if [ -f ".circleci/config.yml" ]; then
            mv .circleci/config.yml .circleci/config.yml.disabled
            echo "✓ Disabled CircleCI configuration"
        fi
        # Enable GitHub Actions
        if [ -f ".github/workflows/deploy.yml.disabled" ]; then
            mv .github/workflows/deploy.yml.disabled .github/workflows/deploy.yml
            echo "✓ Enabled GitHub Actions workflow"
        fi
        echo ""
        echo "GitHub Actions configuration complete!"
        echo ""
        echo "Next steps:"
        echo "1. Go to your GitHub repository settings"
        echo "2. Navigate to Settings > Secrets and variables > Actions"
        echo "3. Add the following secrets:"
        echo "   - AWS_ACCESS_KEY_ID"
        echo "   - AWS_SECRET_ACCESS_KEY"
        echo "   - TF_STATE_BUCKET"
        echo "4. Push to main or develop branch to trigger deployment"
        ;;
    3)
        echo ""
        echo "Configuring for manual deployment only..."
        # Disable both
        if [ -f ".circleci/config.yml" ]; then
            mv .circleci/config.yml .circleci/config.yml.disabled
            echo "✓ Disabled CircleCI configuration"
        fi
        if [ -f ".github/workflows/deploy.yml" ]; then
            mv .github/workflows/deploy.yml .github/workflows/deploy.yml.disabled
            echo "✓ Disabled GitHub Actions workflow"
        fi
        echo ""
        echo "CI/CD disabled. Use the scripts in the 'scripts' directory for manual deployment."
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Configuration complete! Remember to commit these changes:"
echo "git add -A"
echo "git commit -m 'Configure CI/CD platform'"
echo ""
