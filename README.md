### Marathon-smartstack

This tool listens to the marathon events endpoint and reacts according to events.

It is supposed to be run as a cronjob

Environment variables needed : 
  
  + ZK_HOSTS : zookeeper hosts, comma separated list
  + HOSTNAME : machine hostname 
  + IP : machine IP
  + NERVE : nerve services directory path 
  + MARATHON : marathon hosts

`docker -v /etc/nerve:/etc/nerve -e MARATHON=<endpoint> ichnaea`

For now it : 
  
  + Rewrites Nerve/Synapse configuration files based on marathon events (works only with docker containers)

This is supposed to be used in combination with the following containers : 
  
  + https://github.com/MacTynow/docker-nerve
  + https://github.com/claydotio/synapse
  + https://github.com/claydotio/synapse

http://nerds.airbnb.com/smartstack-service-discovery-cloud/
