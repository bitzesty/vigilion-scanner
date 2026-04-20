#!/bin/sh
set -eu

cd /usr/src/app
mkdir -p tmp/pids

exec /sbin/setuser app bundle exec puma -C /usr/src/app/config/puma.rb
