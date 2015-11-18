#!/usr/bin/ruby

require 'json'
require 'net/http'
require './client.rb'

zk_hosts = ENV.fetch('ZK_HOSTS')
host = ENV.fetch('HOSTNAME')
ip = ENV.fetch('IP')
nerve_config_path = ENV.fetch('NERVE') || '/etc/nerve/services'
synapse_config_path = ENV.fetch('SYNAPSE') || '/etc/synapse/services'
marathon = ENV.fetch('MARATHON')

ichnaea = Ichnaea.new

apps = ichnaea.request("http://#{marathon}:8080/v2/apps")

apps['apps'].each do |app|
  target = ichnaea.request("http://#{marathon}:8080/v2/apps/#{app['id']}")
  if target['app']['healthChecks'].empty? == false
    i = 1

    if target['app']['container']['docker'].key?('portMappings')
      target['app']['tasks'].each do |task|
        # wrote_file = false
        id = target['app']['id'].tr("/", "")

        if File.exist?("#{synapse_config_path}/#{id}.json}") == false
          synapse_conf = ichnaea.build_synapse_json(zk_hosts, app)
          ichnaea.write_config(synapse_config_path, id, synapse_conf)
        end

        if task['host'].include?(host) && File.exist?("#{nerve_config_path}/#{id}#{i}.json") == false
          nerve_conf = ichnaea.build_nerve_json(ip, zk_hosts, app, task)
          ichnaea.write_config(nerve_config_path, "#{id}#{i}", nerve_conf)
          # wrote_file = true
          i += 1
        # elsif wrote_file == false && File.exist?("#{nerve_config_path}/#{id}#{i}.json")
        elsif task['host'].include?(host) == false && File.exist?("#{nerve_config_path}/#{id}#{i}.json")
          ichnaea.delete_config(nerve_config_path, "#{id}#{i}")
        end
      end
    end
  end
end
