FROM phusion/baseimage:focal-1.2.0 AS clamav-builder

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
              gcc \
              make \
              python3 \
              python3-pip \
              python3-pytest \
              curl \
              ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    # Install Rust and Cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
    . $HOME/.cargo/env; \
    \
    curl -L -o clamav.tar.gz https://www.clamav.net/downloads/production/clamav-1.3.1.tar.gz; \
    tar xzf clamav.tar.gz; \
    cd clamav-1.3.1; \
    mkdir build && cd build; \
    cmake .. \
      -D CMAKE_BUILD_TYPE="Release" \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D APP_CONFIG_DIRECTORY=/etc/clamav \
      -D DATABASE_DIRECTORY=/var/lib/clamav \
      -D ENABLE_JSON_SHARED=ON \
      -D CMAKE_INSTALL_LIBDIR=/usr/lib \
      -D ENABLE_CLAMONACC=OFF \
      -D ENABLE_EXAMPLES=OFF \
      -D ENABLE_MAN_PAGES=OFF \
      -D ENABLE_MILTER=ON \
      -D ENABLE_STATIC_LIB=OFF \
    ; \
    make DESTDIR="/clamav" --quiet -j$(($(nproc) - 1)) install; \
    cd ../../ && rm -r clamav.tar.gz clamav-1.3.1; \
    rm -rf "/clamav/usr/include" \
           "/clamav/usr/lib/pkgconfig/" \
           "/clamav/usr/share/doc" ; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -qqy --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM phusion/baseimage:focal-1.2.0 AS ruby-builder
##
# based on Dockerfile for ruby:2.7.7

# skip installing gem documentation
RUN set -eux; \
    mkdir -p /usr/local/etc; \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

ENV LANG=C.UTF-8
ENV RUBY_MAJOR=3.3
ENV RUBY_VERSION=3.3.9
ENV RUBY_DOWNLOAD_SHA256=2b24a2180a2f7f63c099851a1d01e6928cf56d515d136a91bd2075423a7a76bb

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
    libyaml-dev \
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
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH=$GEM_HOME/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM phusion/baseimage:focal-1.2.0

COPY --from=ruby-builder "/usr" "/usr"
COPY --from=clamav-builder "/clamav" "/"

COPY config/freshclam.conf /etc/clamav/freshclam.conf
COPY config/clamd.conf /etc/clamav/clamd.conf
RUN chmod 644 /etc/clamav/clamd.conf /etc/clamav/freshclam.conf

RUN groupadd --system app && \
    useradd --system --create-home --gid app --home-dir /home/app --shell /bin/sh app && \
    mkdir -p /var/lib/clamav /usr/src/app /usr/src/app/tmp/pids \
      /etc/service/clamd /etc/service/freshclam /etc/service/puma /etc/service/sidekiq && \
    chown -R app:app /var/lib/clamav /usr/src/app /usr/local/bundle

WORKDIR /usr/src/app

RUN freshclam --user=app -v && \
    freshclam --version > /usr/src/app/CLAM_VERSION && \
    chown app:app /usr/src/app/CLAM_VERSION

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN gem install bundler:4.0.10

RUN set -eux; \
    \
    apt-get -qq update; \
    apt-get -qqy --no-install-recommends install \
    # for postgresql
            libpq-dev \
            postgresql-client \
    # for libmagic-backed MIME detection
            file \
            libmagic1 \
    # for bundling vigilion gems
            make \
            gcc \
            libyaml-dev \
            libpcre2-dev \
            ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    bundle install --jobs 4 --retry 3 ; \
    \
    apt-mark auto make gcc gcc-9-base libpcre2-dev libyaml-dev > /dev/null; \
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

COPY --chown=app:app . /usr/src/app
COPY docker/av-clamd.sh /etc/service/clamd/run
COPY docker/freshclam.sh /etc/service/freshclam/run
COPY docker/puma.sh /etc/service/puma/run
COPY docker/sidekiq.sh /etc/service/sidekiq/run
RUN chmod +x \
    /etc/service/clamd/run \
    /etc/service/freshclam/run \
    /etc/service/puma/run \
    /etc/service/sidekiq/run

CMD ["/sbin/my_init"]
EXPOSE 3000
