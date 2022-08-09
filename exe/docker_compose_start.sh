#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script is run within the app container!

function wait_for_db() {
  sleep 3

  until pg_isready -h "$1" -U "postgres"; do
    echo "Waiting for postgresql at $1 to start..."
    sleep 2
  done
}
# Could do sanity check of environment here
# * Raise a warning of the database.yml file looks like it is setup for docker-compose

wait_for_db "postgres10_legacy"
wait_for_db "db"

# If database is empty migrate data over from legacy postgres 10 postgres
if psql -h db -U postgres -tAc "SELECT '<'||COUNT(*)||'>' FROM pg_database WHERE datname NOT LIKE 'template%'" | grep -q "<1>"; then
  echo "Migrating from legacy postgres 10 to postgres 12"
  pg_dumpall -h postgres10_legacy -U postgres | psql -h db -U "postgres" -f-
fi


if [ ! -f /app/config/database.yml ]; then
  cp /app/config/database.yml.docker.compose.example /app/config/database.yml
  printf "\n Copying config/database.yml \n"
else
  printf "\n Found config/database.yml \n"
fi

if [ ! -f /app/config/secrets.yml ]; then
  cp /app/config/secrets.yml.example /app/config/secrets.yml
  printf "\n Copying config/secrets.yml \n"
else
  printf "\n Found config/secrets.yml \n"
fi

if [ ! -f /app/config/application_settings.yml ]; then
  cp /app/config/application_settings.yml.docker.compose.example /app/config/application_settings.yml
  printf "\n Copying config/application_settings.yml \n"
else
  printf "\n Found config/application_settings.yml \n"
fi

printf "\n\n  Creating databases (if not exist already) \n\n "
bundle exec rake db:create
printf "\n\n  Starting migration process \n\n"
bundle exec rake db:migrate
echo "Done migration successfully"


if [ -f /app/tmp/pids/server.pid ]; then
   rm /app/tmp/pids/server.pid
fi

bundle exec rails s -p 3000 -b '0.0.0.0'
