# Vigilion Malware Scanner API

Vigilion is an easy to integrate cloud scanning API service for systems that have user file-upload functionality. Our real time anti-malware security solution stops viruses from reaching your users, helping you meet security requirements of IT Health Checks (ITHC) for your cloud services.

It also contains the models for company accounts and plans, and scanning API keys, however now this is open source, you can create a plan with no limit and assign that to each accounts API key.

The ClamAV detection engine is the default engine - it has heuristics, support for numerous archivers (Zip, Rar, OLE, etc), unpacking support (UPX, PeTite, NSPack, etc), and several different content inspection engines.

Virus definition database updated hourly.

## Scanning Flow

1) User uploads the file to the **client app**

2) The **client app** saves the file on a public accessible
storage (S3 or similar) and calls **Vigilion Scanner** with a
URL to download the file.

3) Vigilion Scanner check the **client app** credentials and if
everything is ok, it schedules the scan using **Sidekiq**.

4) An async process downloads the file and performs the scan, then deletes the file.

5) Once the file was scanned, **Virus Scanner** sends a
callback request to the **client app**

6) The client checks credentials and then updates the file
status accordingly.

There is an alternative flow which instead of sending the URL,
the client app sends the raw file.
In this scenario, **Vigilion Scanner** stores temporarily the
file until the async process analyzes it.

## API methods

### `POST   /scans`
Creates a new scan request and queues it.

Accepted Paramseters:
* `scan[key]`: This is a key to map your model to ours.
The scanner wont do anything with it but it requires to be there. Typically this is the ID of your model in your database.

If scanning a URL of a file:
* `scan[url]`: URL to download the actual file
* `scan[do_not_unencode]`: If using GCP to store files you can request that the URL is not unencoded (values true/false, defaults to false).

Or alternatively, an actual file:
* `scan[file]`: The file.

### `GET    /scans/:id`
Gets information about an specific scan request.
The id is obtained as a response from `POST /scans`

### `GET    /scans`
List all the scans performed.

### `GET    /scans/stats`
Returns an agregation of all the scans performed.
It could be filtered by status.

Example:

```
GET /scans/stats?status=infected
```

## Scan statuses
| Status | Description|
| ------ |:---------------------:|
| pending| The file is queued for scanning.|
| scanning| The scan is being scanned.|
| clean| The scan succeeded and the file is clean.|
| infected| The scan succeeded and the file was infected.|
| error| Unable to scan the file.|

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

### Hardware requirements

API server should have at least 4GB of RAM memory and 2GB for storage

### Local Install

Install docker and run:

    docker-compose up

This will build and start the containers. Now need to create the database:

    docker-compose run web rake db:create

Optionally seed database:

    docker-compose run web rake db:seed

#### Setup accounts

List plans:

    docker-compose run web rake plans:list

Create an account using `accounts:create` task. Arguments in required order: plan_id, project_name, callback_url
Example:

    docker-compose run web rake "accounts:create[1,demo,https://localhost/vigilion/callback]"

* Rake task will output details of the account just created, including X-Api-Key required for API requests

#### Setup env vars on Target Rails app side

In .env you need to specify following env variables
```
DISABLE_VIRUS_SCANNER=false # it true by default on localhost
VIRUS_SCANNER_API_URL=http://localhost:5000 # can be different on your side
VIRUS_SCANNER_API_KEY=<API KEY>
```

## Testing

To run specs execute

    docker-compose run web bash

and within container:

    bundle exec rspec

You can also test the API using postman.

# API clients
We have some API clients for the some languages:
* [Ruby](https://github.com/vigilion/vigilion-ruby)
* [Rails](https://github.com/vigilion/vigilion-rails)


# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add test coverage for the feature, We use rspec for this purpose
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

# License

Vigilion scanner is Copyright © 2021 Bit Zesty. It is free
software, and may be redistributed under the terms specified in the
[LICENSE] file.

[LICENSE]: https://github.com/bitzesty/vigilion-scanner/blob/main/LICENSE


# About Bit Zesty

![Bit Zesty](https://bitzesty.com/wp-content/uploads/2017/01/logo_dark.png)

Vigilion malware scanner is maintained by Bit Zesty Limited.
The names and logos for Bit Zesty are trademarks of Bit Zesty Limited.

See [our other projects](https://bitzesty.com/client-stories/) or
[hire us](https://bitzesty.com/contact/) to design, develop, and support your product or service.
