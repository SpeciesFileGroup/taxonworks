#!/bin/bash
cd "$(dirname "$0")"

#set -e
#set -x

docker build .. -t sfgrp/taxonworks --build-arg REVISION=$(git rev-parse --short HEAD)

export REVISION=$(git rev-parse --short HEAD)

docker-compose up --build -d

docker-compose logs

docker-compose exec test bundle exec rspec -fd

docker-compose down --volumes
