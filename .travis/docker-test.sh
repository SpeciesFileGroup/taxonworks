#!/bin/bash
cd "$(dirname "$0")"

set -e
set -x

export REVISION=$(git rev-parse HEAD | cut -c1-9)

docker build .. -t sfgrp/taxonworks --build-arg REVISION=$REVISION --build-arg BUNDLER_WORKERS=3

for ver in `echo 10 12`; do
  export PG_VERSION=$ver

  echo "Testing with Postgres $PG_VERSION"

  docker-compose build --parallel

  docker-compose up -d --no-build

  docker-compose logs

  docker-compose exec test bundle exec rspec -fd

  # Test redis is running
  docker-compose exec taxonworks redis-cli ping

  # Test deploy-time backup is restorable
  docker-compose exec taxonworks find /backup | grep dump || (echo "BACKUP AT STARTUP WAS NOT MADE!" && exit 1) # Check backup was made at startup
  docker-compose exec db psql -U travis -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'travis' AND pid <> pg_backend_pid();"
  docker-compose exec taxonworks bundle exec rake tw:db:restore_last DISABLE_DATABASE_ENVIRONMENT_CHECK=1
  docker-compose down --volumes
done
