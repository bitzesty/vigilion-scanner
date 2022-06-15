#!/bin/sh

clamd -F -c /etc/clamav/clamd.conf -l /var/log/clamd.log
