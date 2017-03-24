FROM ubuntu:16.04
MAINTAINER Matt Yoder
ENV LAST_FULL_REBUILD 2017-03-19

# postgis* postgresql # Check star

RUN apt-get update && \
    apt-get install -y software-properties-common && \ 
    apt-get install -y git gcc nodejs build-essential libffi-dev libgdbm-dev libncurses5-dev libreadline-dev libssl-dev libyaml-dev zlib1g-dev libcurl4-openssl-dev  && \
    apt-get install -y pkg-config imagemagick libmagickcore-dev libmagickwand-dev  && \
    apt-get install -y tesseract-ocr && \
    apt-get install -y cmake   

RUN apt-get install -y libpq-dev libproj-dev libgeos-dev libgeos++-dev 

RUN apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.3 ruby2.3-dev 

# apt-get Passenger config
# https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    apt-get install -y apt-transport-https ca-certificates && \
    sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list' && \
    apt-get update && \
    apt-get install -y nginx-extras passenger

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

# Configure Bundler to install everthing globaly
ENV GEM_HOME /usr/lcoal/bundle
ENV PATH $GEM_HOME/bin:$PATH

RUN gem install bundler && \
    bundler config --global path "$GEM_HOME" && \
    bundle config --global bin "$GEM_HOME/bin" && \
    mkdir /app

# COPY config/docker/files/nginx-sites.conf /etc/nginx/sites-enabled/default
# COPY config/docker/files/supervisord.conf /etc/supercisor/conf.d/supervisord.conf

# CMD are executed in /app
WORKDIR /app

ENV BUNDLE_APP_CONFIG $GEM_HOME

# At this point /app is empty
COPY Gemfile /app/
COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install  

# 
COPY . /app
# TODO: make a variable
# RUN bundle exec rake assets:precompile RAILS_ENV=development

COPY ./config/database.yml.example /app/config/database.yml

COPY ./config/application_settings.yml.example /app/config/application_settings.yml

CMD ["rails", "server"] # there is only one

# CMD rackup

# sudo chown root: /etc/apt/sources.list.d/passenger.list
# sudo chmod 655 /etc/apt/sources.list.d/passenger.list

# sudo apt-get update
# sudo apt-get install -y nginx-extras passenger

# Manually complete:
# Edit /etc/nginx/nginx.conf and uncomment passenger_root and passenger_ruby. 
# sudo service nginx restart



