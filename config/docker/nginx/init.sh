#! /bin/bash
cd /app

# Source files are coming from local, copied to 
bundle exec erb /app/config/docker/nginx/webapp.conf.erb  > /etc/nginx/sites-enabled/webapp.conf
bundle exec erb /app/config/docker/nginx/secret_key.conf.erb  > /etc/nginx/main.d/secret_key.conf 

bundle exec erb /app/config/docker/secrets.yml.erb > /app/config/secrets.yml
bundle exec erb /app/config/docker/database.yml.erb > /app/config/database.yml

npm install
