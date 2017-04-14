
to be moved to a tw_provision 

# Overview

* Dockerfile is configured for production using kubernetes/minikube
* Dockerfile.development is configured to use with docker-compose 

# TODO

* Resolve media in Dockerfile/kubernetes
* Resolve migration process in kubernetes, including fallback

# Development quick start

_Assumes you have taxonworks cloned, and docker started. This is an empty (no data) TW instance. See below for restoring/adding data._

* `cd /path/to/taxonworks`
* `git checkout docker`
* `cp config/database.yml.docker.compose config/database.yml`
* `docker-compose build`
* `docker-compose up`
* browse to `127.0.0.1:3000`
* ... do stuff ...
* `docker-compose down`

# Docker notes

## Rebuilding production

Uses Dockerfile.  Ultimately will track /SpeciesFileGroup/master and build on commits.

* `docker build --rm -t sfgrp/taxonworks .` 
* `docker push sfgrp/taxonworks`

# Kubernetes/Minikube notes 

See also [https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/](kubectl-cheatsheet)

## One time setup of minikube 

* Set context: (run once, OS X version):

    #!/bin/bash
    export CONTEXT=$(kubectl config view | awk '/current-context/ {print $2}')
    kubectl config set-context $CONTEXT --namespace=tw

* Add autocompletion for kubectl (modifies profile): `source <(kubectl completion bash)` 
* Create namespace for tw in minikube `kubectl create namespace tw`

## Location

* `cd taxworks/k8s`

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

## Run a proxy 

* `kubectl proxy` (localhost:8001)
* In the browser: `http://127.0.0.1:8001/ui` (don't forget the /ui)

## Connect to postgres

* See docker/secrets.yml for secrets

* `psql -U tw -p 31867 -h 192.168.99.100 taxonworks_production` 
* `pg_restore -U tw -p 31867 -h 192.168.99.100 -d taxonworks_production /path/to/pg_dump.dump` # ignore errors re 'roles'

## Cleanup

## All at once
* `kubectl delete -f .`

## Notes

* vi in container acts funny, apt install vim as a work around 
# docker-compose

Using `docker-compose` starts containers that reference your local filesystem referencing `Dockerfile.development`.  

## TODO

* Push `sfgrp/taxonworks-development` to docker hub based off Dockerfile.development.  Until then `docker-compose build` to start.

## Basic use

* [https://docs.docker.com/](Docker docs)

* `docker-compose build`
* `docker-compose down`
* `docker-compose up`
* `docker ps`
* `docker exec -it taxonworks_app_1 bash`
* `docker stop 3dc4293eg17e`  

## postgres

### Restore a database dumped from `rake tw:db:dump`. 

_Hackish!_

* Ensure the app is not running:
* `docker ps` get id
* `docker stop 3dc4293eg17e` 
* `psql -U postgres -p 15432 -h 0.0.0.0 taxonworks_development` connect directly to the PSQL instance
* Drop and create taxonworks_development, exit: `\c postgres`, `drop database taxonworks_development;`, `create database taxonworks_development;`, `\q` 
* Restore, errors about roles can be ignored.  The process will "fail" but be successful: `pg_restore -U postgres -p 15432 -h 0.0.0.0 -d taxonworks_development /path/to/pg_dump.dump` 

# Development

## Create a user

* Shell into your app (see above)
* `rails c`
*  `User.create!(name: 'you', password: 'password', password_confirmation: 'password', self_created: true, is_administrator: true, email: 'user@example.com')`
* `quit`

## Use a debugger 

Two steps.  Run docker-compose in daemon mode, then attach to the app. Server log/debugger entry point will appear in the window after requests.

* `docker-compose up -d`
* `docker attach taxonworks_app_1` 

## Troubleshooting

### "docker-compose up" fails

* With `A server is already running. Check /app/tmp/pids/server.pid.` If a the app container is not shut down correctly it can leave `tmp/server.pid` in place.  Delete this file on the local system.
* With `(Bundler::GemNotFound)`. Rebuild the containers: `docker-compose build`

### Misc

* Cleanup old containers.  Try `docker images` and `docker rmi <id>` to cleanup old iamges. 
* If you are debugging docker/kubernetes you may need to log to STDOUT, see `config/application.rb`

