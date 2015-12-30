## The WatchBots Nexus

### Dependencies

* Node.js
* Ruby 2.2
* PhantomJS (http://www.http://phantomjs.org/)
* InfluxDB (https://influxdata.com/time-series-platform/influxdb/)
* Redis
* One or more WatchBots probes

### Quicklaunch for Development

With Ruby installed, run the following lines from the root of your project download:

```sh
bundle install
```

To start the API server :
```sh
rails s -b 0.0.0.0
```

To start the resque jobs :
```sh
QUEUE=* rake environment resque:work
```

### The docker way

TODO...

### Configuration

TODO:
* How to configure probes
* How to configure resque
* How to configure influxdb
* How to configure database
