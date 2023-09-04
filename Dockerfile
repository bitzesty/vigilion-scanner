FROM phusion/baseimage:focal-1.1.0 AS clamav-builder

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get -qq update; \
    apt-get -qqy --no-install-recommends install \
              build-essential \
              cmake \
              git \
              check \
              libcurl4-openssl-dev \
              libssl-dev \
              zlib1g-dev \
              libbz2-dev \
              libxml2-dev \
              libpcre2-dev \
              libjson-c-dev \
              libncurses5-dev \
              valgrind \
              pkg-config \
              libmilter-dev \
              ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    curl -L -o clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.104.2.tar.gz; \
    tar xzf clamav.tar.gz; \
    cd clamav-0.104.2; \
    mkdir build && cd build; \
    cmake .. \
      -D CMAKE_BUILD_TYPE="Release" \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D APP_CONFIG_DIRECTORY=/etc/clamav \
      -D DATABASE_DIRECTORY=/var/lib/clamav \
      # update after upgrading json-c:
      -D ENABLE_JSON_SHARED=ON \
      -D CMAKE_INSTALL_LIBDIR=/usr/lib \
      -D ENABLE_CLAMONACC=OFF \
      -D ENABLE_EXAMPLES=OFF \
      -D ENABLE_MAN_PAGES=OFF \
      -D ENABLE_MILTER=ON \
      -D ENABLE_STATIC_LIB=OFF \
    ; \
    make DESTDIR="/clamav" --quiet -j$(($(nproc) - 1)) install; \
    cd ../../ && rm -r clamav.tar.gz clamav-0.104.2; \
    rm -rf "/clamav/usr/include" \
           "/clamav/usr/lib/pkgconfig/" \
           "/clamav/usr/share/doc" ; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -qqy --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM phusion/baseimage:focal-1.1.0 AS ruby-builder
##
# based on Dockerfile for ruby:2.7.7

# skip installing gem documentation
RUN set -eux; \
    mkdir -p /usr/local/etc; \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

ENV LANG C.UTF-8
ENV RUBY_MAJOR 2.7
ENV RUBY_VERSION 2.7.7
ENV RUBY_DOWNLOAD_SHA256 b38dff2e1f8ce6e5b7d433f8758752987a6b2adfd9bc7571dbc42ea5d04e3e4c

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get -qq update; \
  apt-get install -qqy --no-install-recommends \
    bison \
    dpkg-dev \
    libgdbm-dev \
    ruby \
    autoconf \
    gcc \
    libssl-dev \
    zlib1g-dev \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
  curl -o ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"; \
  echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
  \
  mkdir -p /usr/src/ruby; \
  tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
  rm ruby.tar.xz; \
  \
  cd /usr/src/ruby; \
  \
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
  { \
    echo '#define ENABLE_PATH_CHECK 0'; \
    echo; \
    cat file.c; \
  } > file.c.new; \
  mv file.c.new file.c; \
  \
  autoconf; \
  gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
  ./configure \
    --silent \
    --build="$gnuArch" \
    --disable-install-doc \
    --enable-shared \
  ; \
  make --quiet -j "$(nproc)"; \
  make --quiet install; \
  \
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark > /dev/null; \
  find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | grep -vE '^/usr/local/lib/' \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
  ; \
  apt-get purge -qqy --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  \
  cd /; \
  rm -r /usr/src/ruby; \
# verify we have no "ruby" packages installed
  if dpkg -l | grep -i ruby; then exit 1; fi; \
  [ "$(command -v ruby)" = '/usr/local/bin/ruby' ]; \
# rough smoke test
  ruby --version; \
  gem --version; \
  bundle --version

# don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM phusion/baseimage:focal-1.1.0

COPY --from=ruby-builder "/usr" "/usr"
COPY --from=clamav-builder "/clamav" "/"

COPY config/freshclam.conf /etc/clamav/freshclam.conf
COPY config/clamd.conf /etc/clamav/clamd.conf

RUN groupadd clamav
RUN useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav
RUN mkdir -p /var/lib/clamav && chown -R clamav:clamav /var/lib/clamav

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN freshclam -v && freshclam --version > /usr/src/app/CLAM_VERSION

##
# refresh virus definitions each 1 hour. ClamAV recommends not update in times multiple of 10
RUN echo "15 * * * * root /usr/bin/freshclam --quiet >/dev/null 2>&1 \n" >> /etc/cron.d/freshclam-cron
RUN echo "30 * * * * root /usr/bin/freshclam --version > /usr/src/app/CLAM_VERSION\n" >> /etc/cron.d/freshclam-version-cron

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN gem install bundler:1.17.3

RUN set -eux; \
    \
    apt-get -qq update; \
    apt-get -qqy --no-install-recommends install \
    # for postgresql
            libpq-dev \
            postgresql-client \
    # for ruby-filemagic
            libmagic-dev \
    # for bundling vigilion gems
            make \
            gcc \
            libpcre2-dev \
            ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    bundle install --jobs 4 --retry 3 ; \
    \
    apt-mark auto make gcc gcc-9-base libpcre2-dev > /dev/null; \
    apt-get purge -qqy --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    ##
    # clean:
    # we are doing the following so that we:
    # Removing gcc-9-base:amd64 (9.4.0-1ubuntu1~20.04.1)
    apt-get -qqy update; \
    apt-get -qqy autoremove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# link shared libraries
RUN ldconfig

COPY . /usr/src/app

RUN mkdir /etc/service/puma
COPY docker/puma.sh /etc/service/puma/run
RUN chmod +x /etc/service/puma/run

RUN mkdir /etc/service/sidekiq
COPY docker/sidekiq.sh /etc/service/sidekiq/run
RUN chmod +x /etc/service/sidekiq/run

RUN mkdir /etc/service/av-clamd
COPY docker/av-clamd.sh /etc/service/av-clamd/run
RUN chmod +x /etc/service/av-clamd/run

CMD ["/sbin/my_init"]
EXPOSE 3000
