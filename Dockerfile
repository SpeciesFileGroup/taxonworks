FROM phusion/passenger-ruby23:0.9.20
MAINTAINER Matt Yoder
ENV LAST_FULL_REBUILD 2017-03-19

# From Phusion
ENV HOME /root
RUN rm /etc/nginx/sites-enabled/default
ADD config/docker/nginx/gzip_max.conf /etc/nginx/conf.d/gzip_max.conf

# TaxonWorks dependencies

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Nodejs
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN apt update && \
    apt install -y software-properties-common git gcc build-essential \
            libffi-dev libgdbm-dev libncurses5-dev libreadline-dev \
            libssl-dev libyaml-dev zlib1g-dev libcurl4-openssl-dev \
            pkg-config imagemagick libmagickcore-dev libmagickwand-dev \
            tesseract-ocr cmake libpq-dev libproj-dev libgeos-dev libgeos++-dev locales \
            nodejs yarn && \
    apt clean && \ 
    rm -rf /var/lip/abpt/lists/* /tmp/* /var/tmp/* 

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

# Configure Bundler to install everthing globaly
# ENV GEM_HOME /usr/local/bundle
# ENV PATH $GEM_HOME/bin:$PATH

# RUN gem install bundler && \
#     bundler config --global path "$GEM_HOME" && \
#     bundle config --global bin "$GEM_HOME/bin" && \
#     mkdir /app

# ENV BUNDLE_APP_CONFIG $GEM_HOME
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install  

COPY . /app

# See https://github.com/phusion/passenger-docker 
RUN mkdir -p /etc/my_init.d
ADD config/docker/nginx/init.sh /etc/my_init.d/init.sh
RUN chmod +x /etc/my_init.d/init.sh && \
    mkdir /app/tmp && \
    mkdir /app/log && \
    rm -f /etc/service/nginx/down

ENV RAILS_ENV production
RUN npm install 
RUN yarn
RUN bundle exec rake assets:precompile
CMD ["/sbin/my_init"]


