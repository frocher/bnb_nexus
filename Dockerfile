FROM frocher/bnb_base

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
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

# for paperclip image manipulation
RUN apt-get install -y file imagemagick

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# phantomjs
RUN npm install -g phantomjs-prebuilt

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install --without test
RUN rbenv rehash

# All app
COPY . $APP_HOME
