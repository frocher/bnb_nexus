# The BotnBot Nexus

The BotnBot Nexus is the central point of the BotnBot application. It is a Rails API only software used by the [BotnBot frontend application](https://github.com/frocher/bnb_app).

## Before starting : the dependencies

You'll need the following software to make the Nexus run on your system:

* Node.js
* Ruby >= 2.3
* [InfluxDB](https://influxdata.com/time-series-platform/influxdb/)
* [MySQL](https://www.mysql.com)
* a SMTP server
* [one or more BotnBot probes](https://github.com/frocher/bnb_probe)

## Quick launch for Development

The Nexus relies on Figaro for environment variables. You must start to create an *application.yml* file in your *config* directory. You can find an *application.yml.sample* in the *config* directory to copy and adapt.

With Ruby installed, run the following lines from the root of your project download:

You first need to create the MySQL database:
```sh
mysql -u root -e "create database botnbot"
```

Then create the database schema:
```sh
bundle install
rake db:migrate
```

You also need to create the InfluxDB database:
```sh
influx -execute 'create database botnbot'
```

And you are finally ready to start the API server:
```sh
rails s
```

## The docker way

TODO...

```sh
docker run -p 3000:3000 -d nexus bundle exec rails
```


## Configuration

The BotnBot Nexus uses the following environment variables.

This software uses the [Figaro gem](https://github.com/laserlemon/figaro). you can define this variables using an application.yml file or using environment variables.
An application.yml.sample file is included in the config directory.

### Mandatory configuration

| Name  | Default Value | Description  |
| ----- | ------------- | ------------ |
| DEVISE_SECRET_KEY | none | You must generate a Devise key
| RAILS_ENV | development | Don't forget to switch it to production |
| PORT | 3000 | Puma server port |
| PROBES | '[{ "name":"localhost", "host":"localhost", "port":3333}]' | array of probes defined as a json string |
| SECRET_TOKEN | none | Rails needs a secret token |

### External services and mail configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| GOOGLE_ANALYTICS_KEY | none | if you want to track usage statistics |
| MAILER_SENDER | jeeves.thebot@botnbot.com | Mail sender |

### MySQL Configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| DB_HOST | localhost | Database host server |
| DB_NAME | botnbot | Database name |
| DB_PASSWORD | &nbsp; | User password |
| DB_PORT | 3306 | Database port |
| DB_USERNAME | root | User name used to log in |

### InfluxDB Configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| INFLUXDB_HOST | localhost | InfluxDB host server |
| INFLUXDB_DATABASE | botnbot | Database name |
| INFLUXDB_PASSWORD | &nbsp; | User password |
| INFLUXDB_PORT | 8083 | InfluxDB port |
| INFLUXDB_USERNAME | root | User name used to log in |

### OAuth Configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| FACEBOOK_KEY | none | facebook key for omniauth |
| FACEBOOK_SECRET | none | facebook secret for omniauth |
| GITHUB_KEY | none | github key for omniauth |
| GITHUB_SECRET | none | github secret for omniauth |
| GOOGLE_KEY | none | google key for omniauth |
| GOOGLE_SECRET | none | google secret for omniauth |

### Push notifications Configuration

| Name    | Default Value | Description  |
| --------|:---------:| -----|
| PUSH_SUBJECT | none | vapid subject |
| PUSH_PUBLIC_KEY | none | vapid public key |
| PUSH_PRIVATE_KEY | none | vapid private key |
