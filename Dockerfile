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
        pkg-config \
        llvm-3.6 \
        llvm-3.6-dev \
        llvm-3.6-tools \
        clang \
        libpcre3 \
        libpcre3-dev \
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
        libzip-dev \
        bzip2 \
        libbz2-dev

# config clamav user
RUN useradd -ms /bin/bash clamav
RUN mkdir /var/lib/clamav
RUN chown clamav:clamav -R /var/lib/clamav

# build clamav
RUN cd /usr/src && \
    curl -LO https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz && \
    tar xzvf clamav-0.99.2.tar.gz && \
    cd clamav-0.99.2 && \
    ./configure --enable-bzip2 --with-system-llvm --disable-llvm -q && make CFLAGS="-Wall -g -O2 -Wno-unused-variable -Wno-unused-value" -s && make install -s

# link shared libraries
RUN ldconfig

RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc
RUN gem update --system && gem install bundler rake

EXPOSE 3000

WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test --jobs 4

COPY . /app

# ClamAV
COPY config/freshclam.conf /usr/local/etc/freshclam.conf
RUN chmod 0700 /usr/local/etc/freshclam.conf
COPY config/clamd.conf /usr/local/etc/clamd.conf
RUN freshclam -v
RUN clamscan --version > CLAM_VERSION
