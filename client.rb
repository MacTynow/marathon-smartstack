#!/usr/bin/ruby

require 'em-http'
require 'em-eventsource'
require 'json'
require 'em-http/middleware/json_response'
require 'socket'

# TODO : handle first time service runs

def parse(stream)
  stream.each_line do |line|
    yield JSON.parse line
  end
end

def build_nerve_json(host, service, port, zk_hosts, checks )
  conf = {
    :host => host,
    :port => port,
    :reporter_type => "zookeeper",
    :zk_hosts => zk_hosts,
    :zk_path => "/services/#{service}",
    :check_interval => 2,
    :checks => checks
  }
end

# This will actually be done when creating a new service...
# def build_synapse_json(service, zk_hosts, ha_port)
#   conf = {
#     :discovery => {
#       :method => "zookeeper",
#       :path => "/services/#{service}",
#       :hosts => zk_hosts
#     },
#     :haproxy => {
#       :port => ha_port,
#       :listen => ["mode http"]
#     }
#   }
# end

def write_config(service, conf)
  target = open('#{service}.json', 'w')
  target.write (conf)
  target.close
end

EM.run do
  source = EventMachine::EventSource.new("http://#{ENV.fetch('MARATHON')}:8080/v2/events")
  source.inactivity_timeout = 0
  source.retry = 1 

  zk_hosts = ENV.fetch('ZK_HOSTS')

  # TODO determine hostname
  #host = socket.ip_address_list.detect{|intf| intf.ipv4_private?}

  source.message do |message|
    parsed_message = parse(message)
    conf = build_nerve_json(host, parsed_message['appId'], parsed_message['port'], zk_hosts, parsed_message['checks'])
    write_config(parsed_message['appId'], conf)
    # puts "new message #{message}"
  end

  source.error do |error|
    puts "error #{error}"
  end

  source.start # Start listening
end