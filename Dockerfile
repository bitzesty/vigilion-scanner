FROM bitzesty/vigilion-scanner-baseimage:release-2.0

# so that we sync in dev
COPY . /usr/src/app

RUN mkdir /etc/service/sidekiq
COPY docker/sidekiq.sh /etc/service/sidekiq/run
RUN chmod +x /etc/service/sidekiq/run

RUN mkdir /etc/service/puma
COPY docker/puma.sh /etc/service/puma/run
RUN chmod +x /etc/service/puma/run
