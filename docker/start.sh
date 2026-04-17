#!/bin/sh
set -eu

cd /usr/src/app
mkdir -p tmp/pids

freshclam --quiet || true
freshclam --version > /usr/src/app/CLAM_VERSION || true

(
  while true; do
    sleep 3600
    freshclam --quiet || true
    freshclam --version > /usr/src/app/CLAM_VERSION || true
  done
) &
freshclam_pid=$!

clamd -F -c /etc/clamav/clamd.conf &
clamd_pid=$!

bundle exec sidekiq -q default -c 2 &
sidekiq_pid=$!

bundle exec puma -C /usr/src/app/config/puma.rb &
puma_pid=$!

cleanup() {
  kill "$puma_pid" "$sidekiq_pid" "$clamd_pid" "$freshclam_pid" 2>/dev/null || true
}

trap cleanup INT TERM EXIT
wait "$puma_pid"
