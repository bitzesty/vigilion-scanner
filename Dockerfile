FROM phusion/baseimage:focal-1.1.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...


##
# based on Dockerfile for ruby:2.7.5

# skip installing gem documentation
RUN set -eux; \
    mkdir -p /usr/local/etc; \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

ENV LANG C.UTF-8
ENV RUBY_MAJOR 2.7
ENV RUBY_VERSION 2.7.5
ENV RUBY_DOWNLOAD_SHA256 d216d95190eaacf3bf165303747b02ff13f10b6cfab67a9031b502a49512b516

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
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
    --build="$gnuArch" \
    --disable-install-doc \
    --enable-shared \
  ; \
  make -j "$(nproc)"; \
  make install; \
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
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
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

###
# done building ruby, now vigilion stuff
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update
RUN apt-get -qqy install \
    # for postgresql
            libpq-dev \
            postgresql-client \
    # # for clamAV
    #         clamav \
		# 				clamav-daemon \
		# 				clamav-freshclam \
    #         build-essential \
    # for building clamav
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
    # for ruby-filemagic
            libmagic-dev

# # permission juggling
# RUN mkdir /var/run/clamav && \
#     chown clamav:clamav /var/run/clamav && \
#     chmod 750 /var/run/clamav

# RUN chown clamav:clamav /etc/clamav /etc/clamav/clamd.conf /etc/clamav/freshclam.conf

# build clamav
RUN set -eux; \
    curl -L -o clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.104.2.tar.gz; \
    tar xzf clamav.tar.gz; \
    cd clamav-0.104.2; \
    mkdir build && cd build; \
    cmake .. \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D APP_CONFIG_DIRECTORY=/etc/clamav \
      -D DATABASE_DIRECTORY=/var/lib/clamav \
      # -D ENABLE_JSON_SHARED=OFF \
      -D CMAKE_INSTALL_LIBDIR=/usr/lib \
    ; \
    cmake --build .; \
    ctest; \
    cmake --build . --target install; \
    cd ../../ && rm -r clamav.tar.gz clamav-0.104.2;

COPY config/freshclam.conf /etc/clamav/freshclam.conf
COPY config/clamd.conf /etc/clamav/clamd.conf

RUN groupadd clamav
RUN useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav
RUN mkdir -p /var/lib/clamav && chown -R clamav:clamav /var/lib/clamav

RUN freshclam -v && freshclam --version > /usr/src/app/CLAM_VERSION

###
# clamav done

# refresh virus definitions each 1 hour. ClamAV recommends not update in times multiple of 10
RUN echo "15 * * * * root /usr/bin/freshclam --quiet >/dev/null 2>&1 \n" >> /etc/cron.d/freshclam-cron
RUN echo "30 * * * * root /usr/bin/freshclam --version > /usr/src/app/CLAM_VERSION\n" >> /etc/cron.d/freshclam-version-cron

# link shared libraries
RUN ldconfig

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN gem install bundler:1.17.3
RUN bundle install --jobs 4 --retry 3

RUN mkdir /etc/service/puma
COPY docker/puma.sh /etc/service/puma/run
RUN chmod +x /etc/service/puma/run

###
# clear phusion/baseimage
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
