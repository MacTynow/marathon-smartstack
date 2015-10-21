#!/usr/bin/ruby

require 'json'
require 'net/http'
require './client.rb'

# These should be passed by salt
ichnaea = Ichnaea.new

zk_hosts = ENV.fetch('ZK_HOSTS')
host = ENV.fetch('HOSTNAME')
ip = ENV.fetch('IP')
nerve_config_path = ENV.fetch('NERVE') || '/etc/nerve/services'
marathon = ENV.fetch('MARATHON')

apps = ichnaea.request("http://#{marathon}:8080/v2/apps")

apps['apps'].each do |app|
  target = ichnaea.request("http://#{marathon}:8080/v2/apps/#{app['id']}")
  if target['app']['healthChecks'].empty? == false
    wrote_file = false
    i = 1

    if target['app']['container']['docker'].key?('portMappings')
      target['app']['tasks'].each do |task|
        id = target['app']['id'].tr("/", "")

        if task['host'].include?(host) 
          conf = ichnaea.build_nerve_json(ip, zk_hosts, app, task)
          ichnaea.write_config(nerve_config_path, "#{id}#{i}", conf)
          wrote_file = true
          i += 1
        elsif wrote_file == false && File.exist?("#{nerve_config_path}/#{id}#{i}.json")
          ichnaea.delete_config(nerve_config_path, id)
        end
      end
    end
  else
    puts "Not writing conf for #{app['id']} since there is no healthChecks configured in marathon"
  end
end