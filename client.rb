#!/usr/bin/ruby

require 'json'
require 'net/http'

def build_nerve_json(host, zk_hosts, app, task)
  return {
    :host => host,
    :port => task['ports'].join,
    :reporter_type => "zookeeper",
    :zk_hosts => zk_hosts.split(','),
    :zk_path => "/services#{app['id']}",
    :check_interval => 2,
    :checks => app['healthChecks']
  }
end

def request(uri)
  url = URI.parse(uri)
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  return JSON.parse res.body
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

def write_config(path, service, conf)
  puts "Writing #{service} configuration file"
  File.open(File.dirname("#{path}") + "#{service}.json", 'w') do |f|
    f.write(conf.to_json)
  end
end

def delete_config(path, service)
  puts "Removing #{service} configuration file"
  File.delete(File.dirname("#{path}") + "#{service}.json") if File.exist?(File.dirname("#{path}") + "#{service}.json")
end

# These should be passed by salt
zk_hosts = ENV.fetch('ZK_HOSTS')
host = ENV.fetch('HOSTNAME')
ip = ENV.fetch('IP')
nerve_config_path = ENV.fetch('NERVE') || '/etc/nerve/services/'
marathon = ENV.fetch('MARATHON')

apps = request("http://#{marathon}:8080/v2/apps")

apps['apps'].each do |app|
  target = request("http://#{marathon}:8080/v2/apps/#{app['id']}")
  wrote_file = false
  i = 1

  target['app']['tasks'].each do |task|
    id = target['app']['id'].tr("/", "")

    if task['host'].include?(host)
      conf = build_nerve_json(host, zk_hosts, app, task)
      write_config(nerve_config_path, "#{id}#{i}", conf)
      wrote_file = true
      i += 1
    elsif !wrote_file && File.exist?("#{id}.json")
      delete_config(nerve_config_path, id)
    end
  end
end


