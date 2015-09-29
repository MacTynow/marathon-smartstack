### Ichnaea

This tool listens to the marathon events endpoint and reacts according to events.

`docker -v /etc/nerve:/etc/nerve -e MARATHON=<endpoint> ichnaea`

For now it : 
+ Rewrites Nerve/Synapse configuration files based on marathon events.