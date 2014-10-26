#!/bin/sh

sudo apt-get update
sudo apt-get install -qq libgeos-dev libproj-dev #postgresql-9.1-postgis
# Allow web browsers in JS feature tests to work
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
