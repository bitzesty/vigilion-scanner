#!/bin/sh
cd /usr/src/app && exec bundle exec puma -C /usr/src/app/config/puma.rb >>/var/log/puma.log 2>&1
