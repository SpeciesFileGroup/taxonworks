#!/bin/bash
cd "$(dirname "$0")"

#set -e
#set -x

docker build .. -t sfgrp/taxonworks --build-arg REVISION=$(git rev-parse --short HEAD) --build-arg BUNDLER_WORKERS=3

# mdillon/postgis:11-3.0 not available at Docker Hub at this time so building ourselves here from official git repo
docker build https://github.com/postgis/docker-postgis.git#master:/11-3.0 -t mdillon/postgis:11-3.0

export REVISION=$(git rev-parse --short HEAD)

docker-compose build --parallel

docker-compose up -d --no-build

docker-compose logs

docker-compose exec test bundle exec rspec -fd

# Test redis is running
docker-compose exec taxonworks redis-cli ping

docker-compose down --volumes
