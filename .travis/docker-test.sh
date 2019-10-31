#!/bin/bash
cd "$(dirname "$0")"

#set -e
#set -x

docker build .. -t sfgrp/taxonworks --build-arg REVISION=$(git rev-parse --short HEAD) --build-arg BUNDLER_WORKERS=3

export REVISION=$(git rev-parse --short HEAD)

docker-compose build --parallel

docker-compose up -d --no-build

docker-compose logs

docker-compose exec test bundle exec rspec -fd

# Test redis is running
docker-compose exec taxonworks redis-cli ping

docker-compose down --volumes
