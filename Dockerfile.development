FROM ubuntu:16.04
MAINTAINER Matt Yoder
ENV LAST_FULL_REBUILD 2018-10-05

RUN apt-get update && \
    apt-get install -y curl software-properties-common apt-transport-https && \
    apt clean && \
    rm -rf /var/lip/abpt/lists/* /tmp/* /var/tmp/*

# Update repos
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt install wget
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
    apt-get install -y locales \
                       postgresql-client-10 \
                       git gcc build-essential \
                       libffi-dev libgdbm-dev libncurses5-dev libreadline-dev libssl-dev libyaml-dev zlib1g-dev libcurl4-openssl-dev \
                       pkg-config imagemagick libmagickcore-dev libmagickwand-dev \
                       libpq-dev libproj-dev libgeos-dev libgeos++-dev \
                       tesseract-ocr \
                       cmake \
                       nodejs yarn && \
                       apt clean && \
                       rm -rf /var/lip/abpt/lists/* /tmp/* /var/tmp/*
#
# Install ruby
# Source: https://github.com/drecom/docker-ubuntu-ruby/blob/2.4.4/Dockerfile
#
RUN git clone git://github.com/rbenv/rbenv.git /usr/local/rbenv \
&&  git clone git://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&&  git clone git://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&&  /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&&  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

ENV RBENV_VERSION 2.5.1

RUN eval "$(rbenv init -)"; rbenv install $RBENV_VERSION \
&&  eval "$(rbenv init -)"; rbenv global $RBENV_VERSION \
&&  eval "$(rbenv init -)"; gem update --system \
&&  eval "$(rbenv init -)"; gem install bundler -f \
&& rm -rf /tmp/*

RUN npm rebuild node-sass

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

ENV GEM_HOME /usr/local/bundle

# cludge

ENV PATH /root/.yarn/bin:$PATH 
ENV PATH $GEM_HOME/bin:$PATH
ENV BUNDLE_APP_CONFIG $GEM_HOME

RUN gem install bundler && \
    bundle config --global path "$GEM_HOME" && \
    bundle config --global bin "$GEM_HOME/bin" && \
    mkdir /app

WORKDIR /app
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install

CMD ["exe/docker_compose_start.sh"]

