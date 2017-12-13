FROM bitzesty/vigilion-scanner-baseimage:release-2.2.2

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
