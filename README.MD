# The BotnBot Nexus

The BotnBot Nexus is the central point of the BotnBot application. It is a Rails API only software used by the [BotnBot frontend application](https://github.com/frocher/bnb_app).

## Before starting : the dependencies

You'll need the following software to make the Nexus run on your system:

* Node.js
* Ruby 2.3
* [PhantomJS](http://www.http://phantomjs.org/)
* [InfluxDB](https://influxdata.com/time-series-platform/influxdb/)
* Redis
* a SMTP server
* [one or more BotnBot probes](https://github.com/frocher/bnb_probe)

## Quicklaunch for Development

The Nexus relies on Figaro for environment variables. You must start to create an *application.yml* file in your *config* directory. You can find an *application.yml.sample* in the *config* directory to copy and adapt.

With Ruby installed, run the following lines from the root of your project download:

```sh
bundle install
rake db:migrate
```

You also need to create the InfluxDB database:
```sh
influx -execute 'create database botnbot'
```

And you are finally ready to start sidekiq and the API server:
```sh
foreman start
```

## The docker way

TODO...

```sh
docker run -p 3000:3000 -d nexus bundle exec foreman start
```


## Configuration

the BotnBot Nexus uses the following environment variables :

* DEVISE_SECRET_KEY : you must generate a devise key.
* FACEBOOK_KEY : facebook key for omniauth
* FACEBOOK_SECRET : facebook secret for omniauth
* GITHUB_KEY : github key for omniauth
* GITHUB_SECRET : github secret for omniauth
* GOOGLE_ANALYTICS_KEY : if you want to track usage statistics
* GOOGLE_KEY : google key for omniauth
* GOOGLE_SECRET : google secret for omniauth
* PROBES : array of probes defined as a json string.
* SECRET_TOKEN : rails 4 needs a secret token.
* SPARKPOST_API_KEY : Botnbot currently uses Sparkpost to send alert and report emails.

This software uses the Figaro gem. you can define this variables using an application.yml file or using environment variables.
An application.yml.sample file is included in the config directory.
