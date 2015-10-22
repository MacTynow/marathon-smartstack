#!/usr/bin/ruby

require 'json'
require 'net/http'

class Ichnaea
  def build_nerve_json(host, zk_hosts, app, task)
      return {
        :host => host,
        :port => task['ports'].join,
        :reporter_type => "zookeeper",
        :zk_hosts => zk_hosts.split(','),
        :zk_path => "/services#{app['id']}",
        :check_interval => 2,
        :checks => [
          {
            :type => app['healthChecks'].first['protocol'].downcase,
            :uri => app['healthChecks'].first['path'],
            :timeout => app['healthChecks'].first['timeoutSeconds'],
            :fall => app['healthChecks'].first['maxConsecutiveFailures']
          }
        ]
      }
  end

  def build_synapse_json(zk_hosts, app)
    return {
      :discovery => {
        :method => "zookeeper",
        :path => "/services#{app['id']}",
        :hosts => zk_hosts.split(',')
        },
      :haproxy => {
        :port => app['container']['docker']['portMappings'].first['servicePort'],
        :server_options => "check inter 2s rise 3 fall 2",
        :listen => [
          "mode http"
        ]
      }
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

  def write_config(path, service, conf)
    puts "Writing #{service} configuration file"
    File.open("#{path}/#{service}.json", 'w') do |f|
      f.write(conf.to_json)
    end
  end

  def delete_config(path, service)
    puts "Removing #{service} configuration file"
    File.delete("#{path}/#{service}.json") if File.exist?("#{path}/#{service}.json")
  end
end
