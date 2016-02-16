FROM ruby:2.3.0-slim

ENV NODE_VERSION 0.12.10

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

RUN buildDeps='curl ca-certificates xz-utils' \
        && set -x \
        && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* \
        && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
        && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
        && gpg --verify SHASUMS256.txt.asc \
        && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt.asc | sha256sum -c - \
        && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
        && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc \
        && apt-get purge -y --auto-remove $buildDeps

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
    git \
    wget \
    build-essential \
    g++ \
    flex \
    bison \
    gperf \
    perl \
    libsqlite3-dev \
    libmysqlclient-dev \
    mysql-client \
    libfontconfig1 \
    libfontconfig1-dev \
    libicu-dev \
    libfreetype6 \
    libfreetype6-dev \
    libssl-dev \
    libxft-dev \
    libpng-dev \
    libjpeg-dev

# for image manipulation
RUN apt-get install -y cron

# for image manipulation
RUN apt-get install -y imagemagick

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# phantomjs
RUN npm install -g phantomjs-prebuilt

RUN gem install foreman

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

RUN whenever -c

ADD . $APP_HOME
