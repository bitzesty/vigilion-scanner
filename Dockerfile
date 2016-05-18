FROM ruby:2.3-alpine

RUN apk add --update --no-cache \
    bash \
    build-base \
    nodejs \
    tzdata \
    libxml2-dev \
    libxslt-dev \
    git \
    postgresql-client \
    postgresql-dev \
    curl-dev \
    curl \
    unrar \
    bzip2-dev \
    clamav \
    clamav-daemon

RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc

RUN bundle config build.nokogiri --use-system-libraries

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
