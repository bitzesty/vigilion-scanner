#!/bin/sh

# boot clamd in background
nohup clamd &

# boot avg in background
#nohup service avgd start &

# run sidekiq
cd /usr/src/app && exec bundle exec sidekiq -q default -c 2 >>/var/log/sidekiq.log 2>&1
