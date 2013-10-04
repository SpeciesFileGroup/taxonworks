#!/bin/sh

sudo add-apt-repository -y ppa:mms-prodeia/qlandkarte
sudo apt-add-repository -y ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install libgeos-dev libproj-dev libgdal1h
sudo apt-get install -y --force-yes postgis postgresql-9.1-postgis
sudo apt-get install libgeos++-dev
