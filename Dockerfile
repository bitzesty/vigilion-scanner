FROM ubuntu:14.04

RUN apt-get -qq update

RUN apt-get -qqy install \
    nodejs \
    build-essential \
    tzdata \
    libxml2-dev \
    libxslt-dev \
    git \
    postgresql-client \
    libpq-dev \
    libcurl3 \
    curl \
    unrar-free \
    libzip-dev \
    clamav \
    clamav-daemon

RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc

# https://www.brightbox.com/docs/ruby/ubuntu/
ENV RUBY_VERSION 2.3

# install ruby
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C3173AA6 && \
    echo deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main > /etc/apt/sources.list.d/brightbox-ruby-ng-trusty.list && \
    apt-get -qq update && apt-get -qqy install --no-install-recommends \
        ca-certificates \
        openssl \
        libssl-dev \
        g++ \
        gcc \
        libc6-dev \
        make \
        patch \
        ruby$RUBY_VERSION \
        ruby$RUBY_VERSION-dev

RUN gem install bundler && gem update --system

EXPOSE 3000

WORKDIR /app

# Cache bundler
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test --jobs 4

# Copy the rest of the app
COPY . /app

# ClamAV
COPY config/freshclam.conf /etc/clamav/freshclam.conf
COPY config/clamd.conf /etc/clamav/clamd.conf
RUN freshclam -v 
RUN clamscan --version > CLAM_VERSION
