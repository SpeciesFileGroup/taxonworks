FROM ruby:2.7.4

RUN apt-get update 
RUN apt-get install -y curl bzip2 unzip default-jre \
                       libgtk-3-0 libgtk-3-dev libdbus-glib-1-2 libxt6 # Firefox requirements

RUN curl -sL 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US' | \
    tar -xjf - -C /usr/bin
  
RUN /usr/bin/firefox/firefox --version

ENV PATH /usr/bin/firefox/:$PATH

RUN mkdir /app

WORKDIR /app

RUN wget -q \
    'https://github.com/browserup/browserup-proxy/releases/download/v2.0.1/browserup-proxy-2.0.1.zip' \
&&  unzip browserup-proxy-2.0.1.zip

COPY Gemfile .

RUN bundle install -j3

COPY . .

#CMD ["bundle", "exec", "rspec", "-fd"]
