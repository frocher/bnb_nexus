## The BotnBot Nexus

### Before starting : the dependencies

You'll need the following software to make the Nexus run on your system:

* Node.js
* Ruby 2.3
* [PhantomJS](http://www.http://phantomjs.org/)
* [InfluxDB](https://influxdata.com/time-series-platform/influxdb/)
* Redis
* a SMTP server
* [one or more BotnBot probes](https://github.com/frocher/bnb_probe)

### Quicklaunch for Development

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

### The docker way

TODO...
