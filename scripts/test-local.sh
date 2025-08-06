#!/bin/bash
# Test script to run the application locally with Redis in Docker

set -e

echo "🧪 Starting local test environment..."

# Check if Redis container is already running
if [ "$(docker ps -q -f name=local-redis)" ]; then
    echo "Redis container already running"
else
    echo "Starting Redis container..."
    docker run -d --name local-redis -p 6379:6379 redis:7-alpine
    sleep 2
fi

# Set environment variables
export REDIS_HOST=localhost
export REDIS_PORT=6379
export NODE_ENV=development

# Install dependencies
echo "Installing Node.js dependencies..."
cd app
npm install

# Start the application
echo -e "\n🚀 Starting application..."
echo "Access the app at: http://localhost:3000"
echo "Press Ctrl+C to stop"
npm start
