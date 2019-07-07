FROM ruby:2.5.1-stretch

RUN apt-get update 
RUN apt-get install -y curl bzip2 unzip default-jre \
                       libgtk-3-0 libgtk-3-dev libdbus-glib-1-2 libxt6 # Firefox requirements

RUN curl -sL 'https://download.mozilla.org/?product=firefox-latest&lang=en-US&os=linux64' | \
    tar -xjf - -C /usr/bin
  
RUN /usr/bin/firefox/firefox --version

ENV PATH /usr/bin/firefox/:$PATH

RUN mkdir /app

WORKDIR /app

RUN wget -q \
    'https://github.com/lightbody/browsermob-proxy/releases/download/browsermob-proxy-2.1.4/browsermob-proxy-2.1.4-bin.zip' \ 
&&  unzip browsermob-proxy-2.1.4-bin.zip

COPY Gemfile .

RUN bundle install

COPY . .

CMD ["bundle", "exec", "rspec", "-fd"]