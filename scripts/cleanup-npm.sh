#!/bin/bash
# Clean up corrupted package-lock.json before committing

cd app/

# Remove the corrupted package-lock.json
if [ -f "package-lock.json" ]; then
    echo "Removing corrupted package-lock.json..."
    rm package-lock.json
fi

# Remove backup file if it exists
if [ -f "package-lock.json.backup" ]; then
    echo "Removing package-lock.json.backup..."
    rm package-lock.json.backup
fi

echo "Cleanup complete!"
echo ""
echo "Now you can commit the changes:"
echo "git add app/"
echo "git commit -m 'Fix Docker build: use npm install with cache cleanup'"
echo "git push origin main"
