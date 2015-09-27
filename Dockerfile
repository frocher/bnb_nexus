FROM ruby:2.2.0

ENV PHANTOM_JS_TAG 2.0.0

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
    git \
    build-essential \
    g++ \
    flex \
    bison \
    gperf \
    perl \
    libsqlite3-dev \
    libfontconfig1-dev \
    libicu-dev \
    libfreetype6 \
    libssl-dev \
    libpng-dev \
    libjpeg-dev \
    libqt5webkit5-dev

# for image manipulation
RUN apt-get install -y imagemagick

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs

# build phantomjs
RUN git clone https://github.com/ariya/phantomjs.git /tmp/phantomjs && \
  cd /tmp/phantomjs && git checkout $PHANTOM_JS_TAG && \
  ./build.sh --confirm --jobs 2 && mv bin/phantomjs /usr/local/bin && \
  rm -rf /tmp/phantomjs


ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME
