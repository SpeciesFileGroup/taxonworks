
to be moved to a tw_provision 

# Overview

* Dockerfile is configured for production using kubernetes/minikube
* Dockerfile.development is configured to use with docker-compose 

# TODO

* Resolve media in Dockerfile/kubernetes
* Resolve migration process in kubernetes, including fallback

# Docker notes

## Rebuilding production

Uses Dockerfile.  Ultimately will track /SpeciesFileGroup/master and build on commits.

* `docker build --rm -t sfgrp/taxonworks .` 
* `docker push sfgrp/taxonworks`

# Minikube notes 

# One time setup of minikube 

* Set context: (run once, OS X version):

    #!/bin/bash
    export CONTEXT=$(kubectl config view | awk '/current-context/ {print $2}')
    kubectl config set-context $CONTEXT --namespace=tw

* Add autocompletion for kubectl (modifies profile): `source <(kubectl completion bash)` 
* Create namespace for tw in minikube `kubectl create namespace tw`

## Location

* `cd taxworks/k8s`

## Cleanup

## All at once
* `kubectl delete -f .`

## Startup

### All at once

* `kubectl apply -f .` (start everything, but not recursively)

### Start in pieces

* `kubectl apply -f dev`             # (should see configmap and secret being created)
* `kubectl apply -f pv-claims.yml`   # (claim database space)
* `kubectl apply -f pg.yml`
* `kubectl apply -f app.yml`

### Using the setup

* `kubectl get pod`
* `kubectl exec -it taxonworks-####-##### bash`
* `kubectl logs taxonworks-1122781372-5hm4z`

* `kubectl get service` (get port for service)
* `minikube ip` (get IP for minikube, stable, shouldn't change)

### Run a proxy 

* `kubectl proxy` (localhost:8001)
* In the browser: `http://127.0.0.1:8001/ui` (don't forget the /ui)

### Connect to postgres

* See docker/secrets.yml for secrets

* `psql -U tw -p 31867 -h 192.168.99.100 taxonworks_production` 
* `pg_restore -U tw -p 31867 -h 192.168.99.100 -d taxonworks_production /path/to/pg_dump.dump` # ignore errors re 'roles'

### Notes

* vi in container acts funny, apt install vim as a work around

# docker-compose

* `docker-compose build`
* `docker-compose down`
* `docker-compose up`
* `docker ps`
* `docker exec -it taxonworks_app_1 bash`

## postgres

* `pg_restore -U postgres -p 15432 -h 0.0.0.0 -d taxonworks_development /path/to/pg_dump.dump`
