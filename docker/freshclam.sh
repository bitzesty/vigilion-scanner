#!/bin/sh
set -eu

cd /usr/src/app
/sbin/setuser app freshclam --quiet || true
/sbin/setuser app sh -c 'freshclam --version > /usr/src/app/CLAM_VERSION' || true

exec /sbin/setuser app freshclam \
  --daemon \
  --foreground \
  --stdout \
  --config-file=/etc/clamav/freshclam.conf \
  --daemon-notify=/etc/clamav/clamd.conf
