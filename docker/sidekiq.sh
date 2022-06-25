#!/bin/sh

cd /usr/src/app && exec bundle exec sidekiq -q default -c 2 >>/var/log/sidekiq.log 2>&1
