#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script is run within the app container!

function wait_for_db {
  sleep 3

  until pg_isready -h "db" -U "postgres"; do
    echo "Waiting for postgresql to start..."
    sleep 2
  done
}
# Could do sanity check of environment here
# * Raise a warning of the database.yml file looks like it is setup for docker-compose

wait_for_db

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

# 1) Ensure that we can connect to the database first from within the app container (where this is being run). That is build into this script script the 
# connection string, likely based on the database.yml? Check available environment variables.

# 2) Raise a warning if we can not, and exit, shutting down as cleanly as possible

# 3) Only then do the following (`psql` likely needs to change to something more reflective of the database.yml config for those using non-default settings):

if echo "\c db; \dt" | psql | grep schema_migrations 2>&1 >/dev/null
then
  bundle exec rake db:migrate 
  echo "Done migration successfully"
else
  printf "\n\n  !!!!!!!!!! Building a new taxonworks_development database !!!!!!!!!! \n\n "
  bundle exec rake db:create
  printf "\n\n  Starting migration process \n\n"
  bundle exec rake db:migrate
  echo "Done migration successfully"  
fi


if [ -f /app/tmp/pids/server.pid ]; then
   rm /app/tmp/pids/server.pid
fi

# Why this sleep? Errors we hit at this point are
# likely because webpack has not finished compiling, we
# should create a more specific check here
#
# sleep 60s;


bundle exec rails s -p 3000 -b '0.0.0.0'
