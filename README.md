# Weather station

This is (almost) all of the code required to setup and run the weather station website
at [meteo.fiobbio.com](http://meteo.fiobbio.com).

> **Old**:
> The main set of applications are now containerized and running using the
> Docker container engine.
> The long term goal is to have everything running inside a container,
> and to able to build the whole environment from this Git repository. Even better, use a
> k8s-like platform to manage all containers.

**Update**:
All applications are not containerized and running in a kubernetes cluster!
For simplicity the cluster is a local minikube instance created with the driver
**none** (bare-metal).

## Hardware
* Davis Vantage Pro2
* Raspberry Pi 3
* Cheap chinese webcam

## Software
* Raspbian OS
* Docker
* minikube

### Containers
* [wview](http://www.wviewweather.com): weather data logging + ser2net, rsyslog
* nginx
* rclone for automated backups to Backblaze B2
* Prometheus exporters

## Repository content
* Websites front end
* Automation bash scripts to run periodic actions, e.g. webcam snapshots generation
  and post-processing
* wview archive and config files
* other misc configuration files

## SSL Certificate
```
certbot certonly -d meteo.fiobbio.com --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp
```

## SQLite
### Config Update

```
$ sqlite3 .../wview-conf.sdb
```

```sql
select name,value from config where name="STATION_HOST";
STATION_HOST|ser2net-fiobbio1.default.svc.cluster.local
```

Or using `wviewconfig` in a container:
```
$ docker run -it --rm -v .../wview-conf.sdb:/etc/wview/wview-conf.sdb pullme/x86_64-wview:5.21.7
# wviewconfig
```

### Removing bad database entries

Bad entries are normally caused by no record. That cause temperature (outTemp)
to show as "-17.8 C" -- i.e. "0 F".

Show where there is no record for `outTemp` with:

```sql
select *, datetime (DATETIME(dateTime, 'unixepoch', 'localtime')), outTemp from archive where outTemp is null;
```

Delete:

```sql
delete from archive where outTemp is null;
```
