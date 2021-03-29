# Valheim dedicated linux server files

## Pre-reqs
* SteamCMD - https://developer.valvesoftware.com/wiki/SteamCMD

## Server operation

My game downloads to /home/valheim/**game** and runs as user 'valheim'<br>
I placed the following files there:

* **valheim.sh** - start script
* **valheim.service** - linux systemd service.

To install the systemd service and start via systemctl do this as root (or sudo if that's your thing!)
```
cp valheim.sh /etc/systemd/system/
systemctl enable valheim.service
systemctl start valheim.service
```

## Monitoring

This is a Prometheus pushgateway script so if you want to use it, you will need the following:
* Prometheus-pushgateway - has to be on the game server - https://github.com/prometheus/pushgateway
* Prometheus - this can be on a different server from the game server - https://prometheus.io/

Sample prometheus.yml config
```
scrape_configs:
  - job_name: pushgateway
    honor_labels: false
    static_configs:
      - targets: ['localhost:9091']
```
Push gateway by default runs on TCP/9091.<br>
If you run Prometheus on a different machine from the game server, you will have to substitute 'localhost' in targets above with the hostname of the game server.

I placed my monitoring script in /home/valheim/**monitoring**<br>

* **server.sh** - Prometheus pushgateway script

| Exit code | Meaning |
| --- | --- |
| 1 | server up |
| 0 | server down |

Note: this is basic process-up check, not a functionality check.<br>
If I find the time to figure out how to do a version check and server readiness, I'll re-work it (or you can!)

This can be easily charted in Grafana using "Stat" visualization

## Cron

I run 2 cron jobs, also as user 'valheim', first one to check game server process and second one to a daily restart at 8AM UTC.<br>
I found out that as developer updates the app version, server becomes outdated and users aren't able to connect.

```
1 * * * * /home/valheim/monitoring/server.sh 2>&1 >>/dev/null
0 8 * * * /home/valheim/game/valheim.sh restart 2>&1 >>/dev/null
```
