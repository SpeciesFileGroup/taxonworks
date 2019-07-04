#!/bin/bash
cd "$(dirname "$0")"

set -e
set -x

docker build .. -t sfgrp/taxonworks --build-arg REVISION=$(git rev-parse --short HEAD)
docker-compose up -d

# TODO: Perhaps perform integration test by simulating a browser login in and checking the commit hash is visible
curl -v http://localhost/api/v1/ping

# TODO: Push to Docker Hub here