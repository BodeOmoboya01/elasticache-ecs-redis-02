#!/bin/bash
# Make all shell scripts executable

chmod +x scripts/deploy.sh
chmod +x scripts/destroy.sh
chmod +x scripts/test-local.sh

echo "✓ Made shell scripts executable"
echo ""
echo "Available scripts:"
ls -la scripts/*.sh
