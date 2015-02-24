# Virus Scanner

## Installing Clam AV

    brew install clamav

    modify /usr/local/etc/clamav/freshclam.conf.sample
    save /usr/local/etc/clamav/freshclam.conf (comment out the example line)

    freshclam

## Running

    foreman start

## Testing

`rspec`


## API

This application will receive post requests with a url of a file to download.

This will trigger a Job that:

* Downloads the file
* Scans the file
* Send the scan result back to the requesting web application via a webhook
* Adds a sha1 of the file to a cache for repeat requests


    POST /scan, {url: "URL TO SCAN"}
