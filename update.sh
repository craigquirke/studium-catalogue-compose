#!/bin/bash
echo "Rebuilding studium-app from latest GitHub commit..."
docker compose build --no-cache studium-app

echo "Starting updated container..."
docker compose up -d

echo "Cleaning up old images..."
docker image prune -f

echo "Update complete!"
