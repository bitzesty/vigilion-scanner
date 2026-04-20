#!/bin/sh
set -eu

cd /usr/src/app

exec /sbin/setuser app bundle exec sidekiq -q default -c 2
