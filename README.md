# Virus Scanner

## Installing Clam AV

    brew install clamav

    modify /usr/local/etc/clamav/freshclam.conf.sample
    save /usr/local/etc/clamav/freshclam.conf (comment out the example line)

    freshclam

    (OSX Run Clamd for faster scanning)
    /usr/local/Cellar/clamav/0.98.6/sbin/clamd

## Running

    Load ENV variables

    foreman start

## Testing

`rspec`


## API

This application will receive post requests with a url of a file to download.

This will trigger a Job that:

- [x] Downloads the file into a temp location
- [x] Takes a md5 & sh1 checksum
- [x] Scans the file
- [ ] Send the results back to the requesting web application via a webhook
- [x] Removes temp file

Scan a file

    POST /scan, {url: "URL TO SCAN"}

Check the status of a file

    GET /status/UUID

## Nice to haves

- [ ] If s3 url, use the md5 checksum [sometimes is the etag](http://stackoverflow.com/questions/12186993/what-is-the-algorithm-to-compute-the-amazon-s3-etag-for-a-file-larger-than-5gb) to verify file checksum
- [ ] after downloading the file, check to see if sha1 is has already been scanned, if so return result rather than waste time scanning again (with a force option)
- [ ] HA Squid proxy for clamav updates - min/max 1 auto scaling group + route 53 domain https://aws.amazon.com/articles/6884321864843201
- [ ]
