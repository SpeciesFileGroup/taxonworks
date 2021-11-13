FROM sfgrp/taxonworks-base:ruby3 AS base
ARG BUNDLER_WORKERS=1
ENV RAILS_ENV production

ADD package.json /app/
ADD package-lock.json /app/
ADD .ruby-version /app/
ADD Gemfile /app/
ADD Gemfile.lock /app/

WORKDIR /app

RUN bundle config --local build.sassc --disable-march-tune-native # https://github.com/sass/sassc-ruby/issues/146
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

## Setup delayed_job workers
RUN mkdir /etc/service/delayed_job
RUN cp /app/exe/delayed_job /etc/service/delayed_job/run

RUN chown 9999:9999 /app/public
RUN chown 9999:9999 /app/public/images/tmp
RUN chown 9999:9999 /app/public/packs
RUN chown 9999:9999 /app/log/
RUN chown 9999:9999 /app/downloads
RUN chown 9999:9999 /app/tmp/

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
