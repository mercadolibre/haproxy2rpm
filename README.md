# Push haproxy logs to newrelic rpm
This is useful for languages where newrelic does not provide an agent,
such as erlang or node.js based applications.

It runs in syslog mode or tail a log file.

## Installation

gem install haproxy2rpm or clone it

* copy your newrelic.yml file to $HOME/.newrelic/newrelic.yml
* or set $NRCONFIG to point to your newrelic.yml file

Tell haproxy to log to syslog. e.g:

    # /etc/haproxy/haproxy.cfg
    global
      log 127.0.0.1:3333   daemon

## Running it
    haproxy2rpm /path/to/logfile 
    haproxy2rpm --syslog
    haproxy2rpm --syslog --daemonize
    haproxy2rpm --syslog -c /path/to/config/file.rb

## Configuration

Check the examples folder


## Problems with haproxy timers

Slow clients (e.g mobile clients over an edge connection) influence the
measurements haproxy returns. The same happens for requests that do send
a lot of data (e.g POST/PUT). In that case, the 'tr' value provided by
haproxy is generally a bit higher. When you have many slow clients, it
is significantely higher. For more information about the values haproxy
provides, refer to the [manual](http://code.google.com/p/haproxy-docs/wiki/TimingEvents).

## The issue of the default route

When haproxy2rpm does not find a route, it will record it under a
default name so that NewRelic is not flooded with millions of routes. You can provide by setting 'config.default_route'. 

## Node.js support

Check the examples folder

## Supported RPM features

* Response times in application server
* Error rate
* Queue time
* Apdex
* Histogram
* Web transactions

## Supported Ruby versions

Tested in production

* mri-1.9.2-p180
* ree-1.8.7-2011.03
* mri-1.8.7-p33

Passing manual integration test with test logs

* mri-1.9.3
* mri-1.9.2-p180
* ree-1.8.7-2011.03
* mri-1.8.7-p33
* jruby 1.6.2

rbx-head fails to write to the local db file: 

    Error serializing data to disk: #<TypeError: incompatible marshal file format (can't be read)format version 4.8 required


Passing unit tests

* mri-1.9.2-p180
* ree-1.8.7-2011.03
* mri-1.8.7-p33
* rbx-head
* jruby 1.6.2

## Performance

No performance testing done so fare. Judging by the results of [jordansissel](https://github.com/jordansissel/experiments/tree/master/ruby/eventmachine-speed), MRI 1.9.2 and jRuby should be the fastest.

## Known issues

* Daemonize is broken. Does not work nicely with new relic agent
* Does not work with Rubinius
 
## Roadmap

* Working daemonized mode
* remove haproxy dependency and make it a more generic rpm recorder. Maybe change the name to log2rpm or log4rpm
* Automated benchmarks to see how fast it performs and what Ruby version
  might be best suited for a use case

## Params (20/01/2012)

    haproxy2rpm --help
    Usage: haproxy2rpm [options]
       -c, --config-file FILE           Path to config file
       -d, --daemonize                  Daemonize
       -s, --syslog                     Run syslog server
       -a, --address HOST               Set host address to listen on
       -p, --port PORT                  Set port to listen on
       -n, --app_name APP_NAME          Set application name
       -e, --environment ENVIRONMENT    Set Newrelic agent env
       -P, --pid FILE                   specify Pid file
       -l, --log FILE                   File to redirect output
       -D, --debug                      verbose logging
       -v, --version                    Print the version number and exit
       -h, --help                       Show this message
