

# Notes

* Present docker setup is for *production*, it is not intendend to work with `docker-compose`. It's target is kubectrl.
* Docker file that works with docker-compose is perahaps at  f8858d1

* Rake inside the service was understanding evaulation, Passenger is not

# TODO

## Production

* If database not built, then build and/or restore
* 

# Minikube notes 

# remember to build new images, push to Docker hub

* cd ( ... )

* kubectl delete -f app.yml
* kubectl apply -f app.yml
* get pod
* kubectl exec -it taxonworks-XXXXX-XXXX bash
* cd config

* <apt install vim> (vi screws up 
