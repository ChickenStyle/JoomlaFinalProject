#!/bin/bash

echo "Starting Joomla and MySQL containers..."

if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker not available. Try using sudo or check Docker is running."
  exit 1
fi

docker compose up -d

if docker compose ps | grep -q "Up"; then
  echo "Joomla is running at: http://localhost:8080"
  echo "Logs (Ctrl+C to stop viewing):"
  docker compose logs -f
else
  echo "❌ Containers failed to start."
fi
