#!/bin/bash
cd "$(dirname "$0")"

#set -e
#set -x

docker build .. -t sfgrp/taxonworks --build-arg REVISION=$(git rev-parse --short HEAD)

REVISION=$(git rev-parse --short HEAD) docker-compose up --build --exit-code-from test

docker-compose down --volumes

# TODO: Push to Docker Hub here
