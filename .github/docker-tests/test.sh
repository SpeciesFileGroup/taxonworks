#!/bin/bash
cd "$(dirname "$0")"

set -e
set -x

export REVISION=$(echo $GITHUB_SHA | cut -c1-9)

for ver in `echo 10 12`; do
  export PG_VERSION=$ver

  echo "Testing with Postgres $PG_VERSION"

  docker-compose build --parallel

  docker-compose up -d --no-build

  docker-compose logs

  docker-compose exec -T test bundle exec rspec -fd --force-color
  docker-compose logs
  docker-compose exec taxonworks cat log/production.log

  # Test redis is running
  docker-compose exec -T taxonworks redis-cli ping

  # Test deploy-time backup is restorable
  docker-compose exec -T taxonworks find /backup | grep dump || (echo "BACKUP AT STARTUP WAS NOT MADE!" && exit 1) # Check backup was made at startup
  docker-compose exec -T db psql -U travis -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'travis' AND pid <> pg_backend_pid();"
  docker-compose exec -T taxonworks bundle exec rake tw:db:restore_last DISABLE_DATABASE_ENVIRONMENT_CHECK=1
  docker-compose down --volumes
done
