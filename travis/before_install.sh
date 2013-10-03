#!/bin/sh

echo "yes" | sudo apt-add-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install -y --force-yes libgeos-dev libproj-dev 
sudo apt-get install -y --force-yes postgresql-9.1-postgis
sudo apt-get install -y --force-yes libgeos++-dev
