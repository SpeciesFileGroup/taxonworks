FROM ubuntu:16.04
MAINTAINER Matt Yoder
ENV LAST_FULL_REBUILD 2017-03-19

RUN apt-get update && \
    apt-get install -y software-properties-common && \ 
    apt-get -y install git gcc nodejs build-essential libffi-dev libgdbm-dev libncurses5-dev libreadline-dev libssl-dev libyaml-dev zlib1g-dev libcurl4-openssl-dev  && \
    apt-get install -y libpq-dev libproj-dev libgeos-dev libgeos++-dev postgis* postgresql && \
    apt-get install -y pkg-config imagemagick libmagickcore-dev libmagickwand-dev  && \
    apt-get install -y tesseract-ocr && \
    apt-get install -y cmake 

RUN apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.3 ruby2.3-dev 

# apt-get Passenger config
# https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#install_on_debian_ubuntu
RUN  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 && \
     apt-get install apt-transport-https ca-certificates && \
     echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' | tee /etc/apt/sources.list.d/passenger.list  > /dev/null && \
     apt-get update && \
     apt-get install -y nginx-extras passenger 

RUN locale-gen en US.UTF-8
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

COPY config/docker/files/nginx-sites.conf /etc/nginx/sites-enabled/default
COPY config/docker/files/supervisord.conf /etc/supercisor/conf.d/supervisord.conf

WORKDIR /app

ENV BUNDLE_APP_CONFIG $GEM_HOME

# At this point /app is empty
COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install  

COPY . /app
# TODO: make a variable
RUN bundle exec rake assets:precompile RAILS_ENV=development

CMD ["rails", "s"]

# sudo chown root: /etc/apt/sources.list.d/passenger.list
# sudo chmod 655 /etc/apt/sources.list.d/passenger.list

# sudo apt-get update
# sudo apt-get install -y nginx-extras passenger


# Manually complete:
# Edit /etc/nginx/nginx.conf and uncomment passenger_root and passenger_ruby. 
# sudo service nginx restart



