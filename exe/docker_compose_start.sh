#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function wait_for_db {
  sleep 3

  while [[ $(pg_isready -h "db" \
           -U "taxonworks_development") = "no response" ]]; do
    echo "Waiting for postgresql to start..."
    sleep 1
  done
}

# Could do sanity check of environment here
# * Raise a warning of the database.yml file looks like it is setup for docker-compose

wait_for_db

if [ ! -f /app/config/database.yml ]; then
  cp /app/config/database.yml.docker.compose.example /app/config/database.yml
fi

if [ ! -f /app/config/secrets.yml ]; then
  cp /app/config/secrets.yml.example /app/config/secrets.yml
fi

bundle exec rake db:migrate RAILS_ENV=development

/usr/bin/supervisord -c /app/config/docker/supervisor.conf


