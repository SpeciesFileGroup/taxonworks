#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function wait_for_db {
  sleep 3

  while [[ $(pg_isready -h "db" \
           -U "postgres") = "no response" ]]; do
    echo "Waiting for postgresql to start..."
    sleep 1
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
fi

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

# if bundle exec rake db:migrate RAILS_ENV=development; then

# else
#   printf "\n\n  !!!!!!!!!! Build the taxonworks_development database first. !!!!!!!!!! \n\n "
# fi
if [ -f /app/tmp/pids/server.pid ]; then
   rm /app/tmp/pids/server.pid
fi

sleep 60s;
bundle exec rails s -p 3000 -b '0.0.0.0'
