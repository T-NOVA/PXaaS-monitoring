# PXaaS integration with Monitoring
Two types of metrics are supported:

- Generic metrics using [collectd](https://collectd.org/)
- VNF specific metrics using a Python script and the monitoring API

## Generic metrics
### Requirements

- Collectd version 5.5.1 (Debian comes with collectd v 5.1 so I installed v 5.5.1 manually. I followed [this](https://gagor.pl/2016/01/collectd-installation-and-configuration-with-influxdb-on-debianubuntu/))
- Make sure that the nameserver 10.30.0.11 is defined under /etc/resolv.conf 

### Steps

- Install Collectd v 5.5.1
- Edit [collectd.conf](collectd.conf) under /etc/collectd/collectd.conf
- Change 'Hostname' (VNF's OpenStack instance UUID) with the output of 

```
curl -s http://169.254.169.254/openstack/latest/meta_data.json | sed -e 's/.*"uuid": "//; s/".*//'
```

- Alternative run once the script [init_uuid](init_uuid/init.sh) in order to get the instance UUID automatically at startup
- Define the ip and port of the monitoring server. Change 'server' field under 'Plugin network'
- Define the interface you need to monitor. Change 'Interface' field under 'Plugin interface' 
- Restart collectd

```
sudo service collectd restart
```


## VNF specific metrics
### Metrics sent to the Monitoring Server

- **Number of HTTP requests received**. The number of HTTP requests received by Squid since the last  measurement.
- **Cache hits percentage of all requests**. The percentage of HTTP requests that result in a cache hit for the last 5 minutes. It also includes cases in which Squid validates a cached response and receives a 304 (Not Modified) reply.
- **Cache hits percentage of bytes sent**. The percentage of all data that is transferred directly from the cache rather than from the origin server.
- **Memory hits percentage**. The percentage of all cache hits that were served from memory (hits that are logged as TCP_MEM_HIT in Squid’s logs).
- **Disk hits percentage**. The percentage of all cache hits that were served from disk (hits that are logged as TCP_HIT in Squid’s logs)
- **Cache disk utilization**. The amount of disk currently being used by the cached objects divided by the total amount of disk that can be allocated for caching. 
- **Cache memory utilization**. The amount of memory (RAM) currently being used by the cached objects divided by the maximum amount of memory that can be allocated for caching.
- **Number of users accessing the proxy**. Squid assumes that each user has a unique IP address.

### Requirements

- [squidclient v 3.5.5](http://wiki.squid-cache.org/SquidClientTool). Collects statistics from Squid proxy
- Python 2.7
- [scripts](vnf_specific_metrics) 
- Make sure that the nameserver 10.30.0.11 is defined under /etc/resolv.conf

### Steps

- Make sure that squidclient v3.5.5 and Python 2.7 are installed
- Edit [monitoring.py](vnf_specific_metrics/monitoring.py). Change 'host' and 'port' to the corresponding monitoring server's host and port. Change 'instance_uuid' (see above)    
- Run the script. It sends once the metrics to the monitoring server 

```
python monitoring.py
```

- Create a cron job to send the metrics on time intervals

```
crontab -l > mycron
echo "*/1 * * * * python /home/proxyvnf/monitoring/monitoring.py" >> mycron # executes once a minute
crontab mycron
rm mycron
```