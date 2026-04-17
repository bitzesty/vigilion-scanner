#!/bin/sh
set -eu

exec /sbin/setuser app clamd -F -c /etc/clamav/clamd.conf
