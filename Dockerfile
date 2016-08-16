FROM ubuntu:16.04

# https://www.brightbox.com/docs/ruby/ubuntu/
ENV RUBY_VERSION 2.3

RUN apt-get update && \
    apt-get -qqy install software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng

RUN apt-get -qq update && \
    apt-get -qqy install --no-install-recommends \
        ca-certificates \
        openssl \
        libssl-dev \
        g++ \
        gcc \
        libc6-dev \
        make \
        patch \
        ruby$RUBY_VERSION \
        ruby$RUBY_VERSION-dev \
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
        libzip-dev

# config clamav user
RUN adduser clamav && \
    mkdir /var/lib/clamav && \
    chown clamav:clamav -R /var/lib/clamav

# build clamav
RUN cd /usr/src && \
    curl -LO https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz && \
    tar xzvf clamav-0.99.2.tar.gz && \
    cd clamav-0.99.2 && \
    ./configure -q && make -s && make install -s

# link shared libraries
RUN ldconfig

RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc
RUN gem install bundler && gem update --system

EXPOSE 3000

WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test --jobs 4
COPY . /app

# ClamAV
COPY config/freshclam.conf /usr/local/etc/freshclam.conf
COPY config/clamd.conf /usr/local/etc/clamd.conf
RUN freshclam -v
RUN clamscan --version > CLAM_VERSION
