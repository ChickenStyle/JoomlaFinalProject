#!/bin/bash

echo "Setting up Joomla"

# Check Docker access
if ! docker info > /dev/null 2>&1; then
  echo "Run this command with sudo"
fi

# Create required folders
mkdir -p joomla mysql

# Write docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  joomla:
    image: joomla
    ports:
      - "8080:80"
    depends_on:
      - joomladb
    environment:
      JOOMLA_DB_HOST: joomladb
      JOOMLA_DB_USER: root
      JOOMLA_DB_PASSWORD: my-secret-pw
      JOOMLA_DB_NAME: joomla
    volumes:
      - ./joomla:/var/www/html

  joomladb:
    image: mysql:8.0
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: my-secret-pw
      MYSQL_DATABASE: joomla
    volumes:
      - ./mysql:/var/lib/mysql
EOF


echo "Starting Docker containers..."
docker compose up -d --build

# Wait a few seconds for MySQL to start
sleep 7

# Check container status
if docker compose ps | grep -q "Up"; then
  echo "Joomla is live at: http://localhost:8080"
  echo "Logs (Ctrl+C to stop viewing, containers keep running):"
  docker compose logs -f
else
  echo "Something went wrong. Containers are not running."
fi
