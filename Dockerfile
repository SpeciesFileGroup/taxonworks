FROM phusion/passenger-ruby26:1.0.8 AS base
MAINTAINER Matt Yoder
ENV LAST_FULL_REBUILD 2018-08-10
ARG BUNDLER_WORKERS=1

# From Phusion
ENV HOME /root
RUN rm /etc/nginx/sites-enabled/default
ADD config/docker/nginx/gzip_max.conf /etc/nginx/conf.d/gzip_max.conf

# Update repos
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Until we move to update Ubuntu
RUN apt install wget
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# TaxonWorks dependancies
RUN apt-get update && \
      apt-get install -y locales software-properties-common \ 
      postgresql-client-10 \
      git gcc build-essential \
      libffi-dev libgdbm-dev libncurses5-dev libreadline-dev libssl-dev libyaml-dev zlib1g-dev libcurl4-openssl-dev \
      pkg-config imagemagick libmagickcore-dev libmagickwand-dev \
      libpq-dev libproj-dev libgeos-dev libgeos++-dev \
      tesseract-ocr \
      cmake \
      nodejs yarn \
      redis-server libhiredis-dev && \
      apt clean && \ 
      rm -rf /var/lip/abpt/lists/* /tmp/* /var/tmp/* 

RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV RAILS_ENV production

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'
RUN gem update --system
RUN gem install bundler

ADD package.json /app/
ADD package-lock.json /app/
ADD Gemfile /app/
ADD Gemfile.lock /app/

WORKDIR /app

RUN bundle install -j$BUNDLER_WORKERS --without=development test
RUN npm install

COPY . /app

# See https://github.com/phusion/passenger-docker 
RUN mkdir -p /etc/my_init.d
ADD config/docker/nginx/init.sh /etc/my_init.d/init.sh
RUN chmod +x /etc/my_init.d/init.sh && \
    mkdir /app/tmp && \
    mkdir /app/log && \
    mkdir /app/public/packs && \
    mkdir /app/public/images/tmp && \
    mkdir /app/downloads && \
    chmod +x /app/public/images/tmp && \
    rm -f /etc/service/nginx/down

## Setup Redis.
RUN mkdir /etc/service/redis
RUN cp /app/exe/redis /etc/service/redis/run
RUN cp /app/config/docker/redis.conf /etc/redis/redis.conf

RUN chown 9999:9999 /app/public
RUN chown 9999:9999 /app/public/images/tmp
RUN chown 9999:9999 /app/public/packs
RUN chown 9999:9999 /app/log/
RUN chown 9999:9999 /app/downloads

RUN touch /app/log/production.log
RUN chown 9999:9999 /app/log/production.log
RUN chmod 0664 /app/log/production.log

# Set up REVISION if provided as build-arg
ARG REVISION
RUN [ "x$REVISION" != "x" ] && echo $REVISION > /app/REVISION && \
    echo "Set up REVISION to $REVISION" || true

FROM base AS assets-precompiler

# http://blog.zeit.io/use-a-fake-db-adapter-to-play-nice-with-rails-assets-precompilation/
RUN bundle add activerecord-nulldb-adapter
RUN printf "production:\n  adapter: nulldb" > config/database.yml \
&&  printf "production:\n  secret_key_base: $(bundle exec rake secret)" > config/secrets.yml

# Precompiling and also removing config files just in case someone uses `docker build --target=assets-precompiler`

RUN NODE_OPTIONS="--max-old-space-size=4096" bundle exec rake assets:precompile \
&& rm config/database.yml config/secrets.yml

FROM base
COPY --from=assets-precompiler --chown=9999:9999 /app/public /app/public

CMD ["/sbin/my_init"]
