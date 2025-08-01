#!/bin/bash

echo "Joomla Restore Script"

read -p "Enter backup file name (e.g. joomla-full-backup-2025-08-01_20-00.tar.gz): " BACKUP_NAME
BACKUP_PATH="backups/$BACKUP_NAME"

if [ ! -f "$BACKUP_PATH" ]; then
  echo "❌ Backup file not found: $BACKUP_PATH"
  exit 1
fi

# Extract to temp folder
TEMP_DIR=$(mktemp -d)
echo "Extracting to: $TEMP_DIR"
tar -xzf "$BACKUP_PATH" -C "$TEMP_DIR"

# Restore Joomla folder
if [ -d "$TEMP_DIR/joomla" ]; then
  echo "Restoring Joomla files"
  rm -rf joomla
  mv "$TEMP_DIR/joomla" ./joomla
else
  echo "Joomla folder missing in backup!"
fi

# Find SQL file
SQL_FILE=$(find "$TEMP_DIR" -name "*.sql.gz" | head -n 1)
if [ ! -f "$SQL_FILE" ]; then
  echo "No SQL dump found in backup."
  exit 1
fi

# Start DB container if not running
DB_CONTAINER=$(docker compose ps -q joomladb)
if [ -z "$DB_CONTAINER" ]; then
  echo "joomladb not running. Starting it..."
  docker compose up -d joomladb
  sleep 5
  DB_CONTAINER=$(docker compose ps -q joomladb)
fi

# Restore MySQL
echo "Restoring MySQL"
gunzip -c "$SQL_FILE" | docker exec -i "$DB_CONTAINER" sh -c 'mysql -uroot -p"my-secret-pw"'

# Clean up
rm -rf "$TEMP_DIR"

echo "Joomla Restored :)"

