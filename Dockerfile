FROM phusion/baseimage:master
# Use baseimage-docker's init system.
ENTRYPOINT ["/sbin/my_init", "--"]
CMD ["/sbin/my_init"]


# ruby runtime dependencies
RUN apt-get -qq update && \
    apt-get -qqy install \
                 git \
                 libssl-dev \
                 libcurl4-openssl-dev \
                 libreadline-dev \
                 libmagic-dev

# for building ruby
# https://github.com/docker-library/ruby/blob/be55938d970a392e7d41f17131a091b0a9f4bebc/2.3/Dockerfile
# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.5
ENV RUBY_VERSION 2.5.8
ENV RUBY_DOWNLOAD_SHA256 0391b2ffad3133e274469f9953ebfd0c9f7c186238968cbdeeb0651aa02a4d6d
ENV RUBYGEMS_VERSION 2.7.6.2

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -ex \
	\
	&& buildDeps=' \
		bison \
		dpkg-dev \
		libgdbm-dev \
		ruby \
    wget \
    autoconf \
    gcc \
    zlib1g-dev \
	' \
	&& apt-get install -qqy --no-install-recommends $buildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
	\
	&& mkdir -p /usr/src/ruby \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.xz \
	\
	&& cd /usr/src/ruby \
	\
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
	&& { \
		echo '#define ENABLE_PATH_CHECK 0'; \
		echo; \
		cat file.c; \
	} > file.c.new \
	&& mv file.c.new file.c \
	\
	&& autoconf \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
	&& make -j "$(nproc)" \
	&& make install \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& cd / \
	&& rm -r /usr/src/ruby

RUN gem update --system "$RUBYGEMS_VERSION"

ENV BUNDLER_VERSION 1.17.3

RUN gem install bundler --version "$BUNDLER_VERSION"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# our required packages
RUN apt-get -qq update
RUN apt-get -qqy install \
    # for postgresql
            libpq-dev \
            postgresql-client \
    # for clamAV
            clamav \
						clamav-daemon \
						clamav-freshclam \
            build-essential
    # for AVG

# permission juggling
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

RUN chown clamav:clamav /etc/clamav /etc/clamav/clamd.conf /etc/clamav/freshclam.conf

# END RUBY ONBUILD
RUN freshclam -v && freshclam --version > /usr/src/app/CLAM_VERSION
# END CLAMAV

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# refresh virus definitions each 1 hour. ClamAV recommends not update in times multiple of 10
RUN echo "15 * * * * root /usr/local/bin/freshclam --quiet >/dev/null 2>&1 \n" >> /etc/cron.d/freshclam-cron
RUN echo "30 * * * * root /usr/local/bin/freshclam --version > /usr/src/app/CLAM_VERSION\n" >> /etc/cron.d/freshclam-version-cron

# link shared libraries
RUN ldconfig

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --jobs 4 --retry 3

# so that we sync in dev
COPY . /usr/src/app

RUN mkdir /etc/service/sidekiq
COPY docker/sidekiq.sh /etc/service/sidekiq/run
RUN chmod +x /etc/service/sidekiq/run

RUN mkdir /etc/service/sidekiq-log-forwarder
COPY docker/sidekiq-log-forwarder /etc/service/sidekiq-log-forwarder/run
RUN chmod +x /etc/service/sidekiq-log-forwarder/run

#RUN mkdir /etc/service/puma
#COPY docker/puma.sh /etc/service/puma/run
RUN chmod +x docker/puma.sh

RUN mkdir /etc/service/puma-log-forwarder
COPY docker/puma-log-forwarder /etc/service/puma-log-forwarder/run
RUN chmod +x /etc/service/puma-log-forwarder/run

EXPOSE 3000
