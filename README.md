# Vigilion Scanner [![Circle CI](https://circleci.com/gh/bitzesty/vigilion-scanner.svg?style=svg&circle-token=fdeeca1d75da76a7ed912436b764c9f6497cf4fc)](https://circleci.com/gh/bitzesty/vigilion-scanner)

This app is the responsible for processing files and determine
if they are clean or if they contain viruses.

## Deployment

TODO auto deploy from circle ci/convox grid?

Provision redis & db and then set env variables

local dev, move the docker_compose.yml.local to the main one and move the prod one out of the way (no way to spcify a file path atm). Then run convox start

deploying:

convox deploy --app vigilion-scanner-staging

convox run web bash --app vigilion-scanner-staging
convox run web rake db:migrate --app vigilion-scanner-staging

convox deploy --app vigilion-scanner-production

## Scanning Flow

1) User uploads the file to the **client app**

2) The **client app** saves the file on a public accessible
storage (S3 or similar) and calls **Vigilion Scanner** with a
URL to download the file.

3) Vigilion Scanner check the **client app** credentials and if
everything is ok, it schedules the scan using **SQS Queue**.

4) An async process downloads the file and performs the scan.

5) Once the file was scanned, **Virus Scanner** sends a
callback request to the **client app**

6) The client checks credentials and then updates the file
status accordingly.

There is an alternative flow which instead of sending the URL,
the client app sends the raw file.
In this scenario, **Vigilion Scanner** stores temporarily the
file until the async process analyzes it.

## API methods

### `GET    /scans/stats`
Returns an agregation of all the scans performed.
It could be filtered by status.
Example:
```
GET /scans/stats?status=infected
```

### `GET    /scans`
List all the scans performed.

### `POST   /scans`
Creates a new scan request and queues it.
Params:
* `scan[key]`: This is a key to map your model to ours.
The scanner wont do anything with it but it requires to be there.

* `scan[url]`: URL to download the actual file

Or alternatively:
* `scan[file]`: Instead of sending a URL it sends the actual file.

### `GET    /scans/:id`
Gets information about an specific scan request.
The id is obtained as a response from POST /scans


## Scan status

** pending: The file was not yet scanned.
** scanning: The scan is being scanned.
** clean: The scan succeeded and the file is clean.
** infected: The scan succeeded but the file was infected
** error: The scan has not succedded.
** unknown: Unknown error.

## Application setup

#### STEP 1: Setup clamav antivirus on local

[Installing Clam AV](https://github.com/bitzesty/virus-scanner#installing-clam-av)

#### STEP 2: Set proper env vars to .env file in virus scanner repo

```
AVENGINE=clamdscan
AWS_REGION=<...>
AWS_ACCESS_KEY_ID=<...>
AWS_SECRET_ACCESS_KEY=<...>
SQS_QUEUE=<...>
SECRET_KEY_BASE=<...>
REDIS_URL=
```

#### STEP 3: Populate API account

Here is the rake script https://github.com/bitzesty/virus-scanner/blob/master/lib/tasks/account.rake

Run:
```
account = Account.create!(name: 'test_api_account', callback_url: "http://localhost:3000/vs_rails/scans/callback")

account.api_key
 => kdsjfsf728832....
```

* on Account creation api_key would be generated automatically.

#### STEP 4: Setup env vars on Target Rails app side

In .env you need to specify following env variables
```
DISABLE_VIRUS_SCANNER=false # it true by default on localhost
VIRUS_SCANNER_API_URL=http://localhost:5000 # can be different on your side
VIRUS_SCANNER_API_KEY=<API KEY>
```

#### STEP 5: Run both apps

```
foreman start
```

Target app in this example on 3000 port and virus scanner app on 5000

NOTE: Make sure that in target rails app's Gemfile you have:
```
gem "vs_rails", "~> 0.0.7"
```

## Installing Clam AV

    brew install clamav

    modify /usr/local/etc/clamav/freshclam.conf.sample
    save /usr/local/etc/clamav/freshclam.conf (comment out the example line)

    modify /usr/local/etc/clamav/clamd.conf

    freshclam

    (OSX Run Clamd for faster scanning & MD5 caching)
    /usr/local/Cellar/clamav/0.98.6/sbin/clamd

## Redis

  REDIS needs to be installed and running, can set REDIS_URL

## Running

    Load ENV variables see .env.example

    foreman start

## Testing

To run specs execute
`bundle exec rspec`

You can also test the API using postman
