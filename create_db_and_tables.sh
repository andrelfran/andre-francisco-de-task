#!/bin/bash

# Wait for PostgreSQL to be available
until psql -h "$DB_HOST" -U "$DB_USER" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Run the init.sql script
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f /docker-entrypoint-initdb.d/init.sql
