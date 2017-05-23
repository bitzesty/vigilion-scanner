#!/bin/sh
cd /usr/src/app && exec bundle exec puma -C config/puma.rb >>/var/log/puma.log 2>&1
