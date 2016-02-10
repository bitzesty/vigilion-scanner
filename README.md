# Vigilion Scanner [![Circle CI](https://circleci.com/gh/bitzesty/vigilion-scanner.svg?style=svg&circle-token=fdeeca1d75da76a7ed912436b764c9f6497cf4fc)](https://circleci.com/gh/bitzesty/vigilion-scanner)

This app is the responsible for processing files and determine
if they are clean or if they contain viruses.

## Development

This application use [convox](https://convox.com/docs/) as the workflow for development and deployment. Please follow this [instructions](http://convox.github.io/docs/getting-started/) if you don't have installed the CLI. To use `convox` you will need have installed [Docker](https://www.docker.com/).


Convox uses these files to build and run your development environment:

- A docker-compose.yml
- A Dockerfile to document your build

Once you have installed `Docker` and `Convox` please run this command:

`convox start --file docker-compose-development.yml`

convox start builds and runs the processes declared in your application manifest.

A `CTRL+C` on the convox start process stops everything and exits.

## Deployment

This app can be deployed to Convox via the `convox deploy` CLI command.

Use your Grid API key to log into Grid via the CLI, using your Grid API key as the password.

`convox login grid.convox.com --password <Grid API key>`

##### Create the app

To create an app named `vigilion-scanner-staging` you will have to use this command:

`convox apps create vigilion-scanner-staging`

##### Create the backing services

Provision redis & db

```
convox services create postgres --name pg1
convox services create redis --name rd1
```

And then set env variables:

```
$ convox services info pg1
Name    pg1
Status  running
URL     postgres://postgres:KEDS6tKPZb1iffVB8IXi@pg1.cbm068zjzjcr.us-east-1.rds.amazonaws.com:5432/app

$ convox env set POSTGRES_URL=postgres://postgres:KEDS6tKPZb1iffVB8IXi@pg1.cbm068zjzjcr.us-east-1.rds.amazonaws.com:5432/app

$ convox services info rd1
Name    rd1
Status  running
URL     redis://u:Rn2uRT7g7NJ8iXNAtnSj@rd1-Balancer-124JJ4R695MAR-153811640.us-east-1.elb.amazonaws.com:6379/0

$ convox env set REDIS_URL=redis://u:Rn2uRT7g7NJ8iXNAtnSj@rd1-Balancer-124JJ4R695MAR-153811640.us-east-1.elb.amazonaws.com:6379/0
```


##### Deploy the app


```
convox deploy --app vigilion-scanner-staging
```

To run commands in the staging app:

```
convox run web bash --app vigilion-scanner-staging
convox run web rake db:migrate --app vigilion-scanner-staging
```

##### Logging:

Production logs are streamed to papertrail (credentials are in lastpass)

`matt+staging@vigilion.com`


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

## Testing

To run specs execute
`bundle exec rspec`

You can also test the API using postman
