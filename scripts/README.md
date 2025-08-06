# Local Development Scripts

These scripts are provided for local development and manual operations. For automated deployments, use CircleCI.

## Available Scripts

### test-local.sh

Tests the application locally with Docker Redis.

```bash
./scripts/test-local.sh
```

This will:

- Start a Redis container locally
- Install Node.js dependencies
- Run the application on <http://localhost:3000>

### deploy.sh / deploy.ps1

Manual deployment scripts for local use.

**Linux/macOS:**

```bash
./scripts/deploy.sh
```

**Windows:**

```powershell
.\scripts\deploy.ps1
-AwsRegion "us-east-1"
```

**Note**: For production deployments, use CircleCI instead.

### destroy.sh / destroy.ps1

Manual cleanup scripts for local use.

**Linux/macOS:**

```bash
./scripts/destroy.sh
```

**Windows:**

```powershell
.\scripts\destroy.ps1
```

**Note**: For production cleanup, use the CircleCI cleanup workflow.

## When to Use These Scripts

- **Local Development**: Testing changes before committing
- **Debugging**: Troubleshooting deployment issues
- **Emergency Operations**: When CircleCI is unavailable

## Important Notes

1. These scripts use local AWS credentials
2. Ensure you have the correct AWS profile configured
3. For production, always use CircleCI workflows
4. Manual deployments won't have the same approval gates as CircleCI
