#!/bin/bash

echo "Joomla + MySQL Backup Script"

# Detect MySQL container
DB_CONTAINER=$(docker compose ps -q joomladb)
if [ -z "$DB_CONTAINER" ]; then
  echo "MySQL container is not running. Start it with ./start.sh"
  exit 1
fi

# Config
MYSQLPASSWORD="my-secret-pw"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="backups"
BACKUP_NAME="joomla-full-backup-${TIMESTAMP}"
SQL_FILE="${BACKUP_DIR}/joomla-db.sql.gz"
ARCHIVE="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"

# Ensure backup folder exists
mkdir -p "$BACKUP_DIR"

echo "Dumping MySQL"
docker exec "$DB_CONTAINER" sh -c "exec mysqldump --all-databases -uroot -p$MYSQLPASSWORD" | gzip > "$SQL_FILE"

echo "Creating backup archive: $ARCHIVE"
tar -czf "$ARCHIVE" joomla "$SQL_FILE"

rm "$SQL_FILE"

echo "Backup complete: $ARCHIVE"

