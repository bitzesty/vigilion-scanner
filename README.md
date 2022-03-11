# Vigilion Scanner API [![Circle CI](https://circleci.com/gh/bitzesty/vigilion-scanner.svg?style=svg&circle-token=fdeeca1d75da76a7ed912436b764c9f6497cf4fc)](https://circleci.com/gh/bitzesty/vigilion-scanner)

This app is the responsible for processing files and scanning them to see if they are clean or if they contain viruses.

It also contains the models for company accounts and plans, and scanning API keys.

## Scanning Flow

1) User uploads the file to the **client app**

2) The **client app** saves the file on a public accessible
storage (S3 or similar) and calls **Vigilion Scanner** with a
URL to download the file.

3) Vigilion Scanner check the **client app** credentials and if
everything is ok, it schedules the scan using **Sidekiq**.

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


## Scan statuses

* pending: The file is queued for scanning.
* scanning: The scan is being scanned.
* clean: The scan succeeded and the file is clean.
* infected: The scan succeeded and the file was infected.
* error: Unable to scan the file.

## HTTP Statuses


|Code |	Title                 |	Description                            |
| --- |:---------------------:| :--------------------------------------|
|200  |	OK                    |	The request was successful.            |
|201  |	Created               |	The resource was successfully created. |
|400  |	Bad request           |	Bad request                            |
|422  |	Validation error      |	A validation error occurred.           |
|401  |	Unauthorized          |	Your API key is invalid.               |
|404  |	Not found             |	The resource does not exist.           |
|50X  |	Internal Server Error |	An error occurred with our API.        |


## Application setup

### Install

Install docker and run:

    docker-compose up

This will build and start the containers. Now need to create the database:

    docker-compose run web rake db:create

#### Populate API account

Here is the rake script https://github.com/bitzesty/virus-scanner/blob/master/lib/tasks/account.rake

Run:
```
account = Account.create!(name: 'test_api_account', callback_url: "http://localhost:3000/vs_rails/scans/callback")

account.api_key
 => kdsjfsf728832....
```

* on Account creation api_key would be generated automatically.

#### Setup env vars on Target Rails app side

In .env you need to specify following env variables
```
DISABLE_VIRUS_SCANNER=false # it true by default on localhost
VIRUS_SCANNER_API_URL=http://localhost:5000 # can be different on your side
VIRUS_SCANNER_API_KEY=<API KEY>
```

#### Run both apps

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

## Deploying Convox

    convox switch bitzesty/vigilion-uk

    convox deploy --app api-scanner-staging-g2
    convox run web rake db:migrate --app api-scanner-staging-g2

    convox run web bash --app api-scanner-staging-g2
    convox run web rake some:long_task --detach --app api-scanner-staging-g2

    Production

    convox deploy --app api-scanner-production-g2


## Logging

Staging & Production logs are streamed to papertrail (credentials are in lastpass user`matt+prod@vigilion.com`)
