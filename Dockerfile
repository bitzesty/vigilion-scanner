FROM gliderlabs/alpine:3.2

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base" \
    AV="unrar clamav clamav-daemon bash" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev libffi-dev tzdata yaml-dev libpq postgresql-client postgresql-dev curl" \
    RUBY_PACKAGES="ruby ruby-io-console ruby-json yaml nodejs" \
    RAILS_VERSION="4.2.3"

RUN \
  apk --update --upgrade add $BUILD_PACKAGES $AV $RUBY_PACKAGES $DEV_PACKAGES && \
  gem install -N bundler && \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/*

RUN gem install -N nokogiri -- --use-system-libraries && \
  gem install -N rails --version "$RAILS_VERSION" && \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \

  # cleanup and settings
  bundle config --global build.nokogiri  "--use-system-libraries" && \
  bundle config --global build.nokogumbo "--use-system-libraries" && \
  rm -rf /usr/lib/lib/ruby/gems/*/cache/* && \
  rm -rf ~/.gem

EXPOSE 3000

# ClamAV
ADD config/freshclam.conf /etc/clamav/freshclam.conf
ADD config/clamd.conf /etc/clamav/clamd.conf

RUN freshclam

WORKDIR /app

# cache bundler
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# copy the rest of the app
COPY . /app
