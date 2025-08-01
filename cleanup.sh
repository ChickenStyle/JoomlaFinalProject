#!/bin/bash

echo "Cleaning up Joomla + MySQL Docker environment"

echo "Stopping and removing Docker containers"
docker compose down -v

#Remove site files
if [ -d "joomla" ]; then
  echo "Deleting Joomla files"
  rm -rf joomla
fi

#Remove MySQL data
if [ -d "mysql" ]; then
  echo "Deleting MySQL data"
  rm -rf mysql
fi

echo "Cleanup complete!"

