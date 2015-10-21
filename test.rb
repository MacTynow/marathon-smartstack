#!/usr/bin/ruby

require 'minitest/autorun'
require './client.rb'

describe Ichnaea do
  before do
    @ichnaea = Ichnaea.new
    @app = @ichnaea.request("http://#{ENV.fetch('MARATHON')}:8080/v2/apps/registry")
    @registry = {
      :host => "test",
      :port => @app['app']['tasks'].first['ports'].join,
      :reporter_type => "zookeeper",
      :zk_hosts => [
        "zk01"
      ],
      :zk_path => "/services/registry",
      :check_interval => 2,
      :checks => [
        {
          :type => "http",
          :uri => "/v2/",
          :timeout => 20,
          :fall => 3
        }
      ]
    }
    # @zk_hosts = ['zk01', 'zk02', 'zk03']
  end

  describe "#request" do 
    it "gets the registry app json" do
      @app.wont_be :empty?
    end
  end

  describe "#build nerve config" do
    it "builds the configuration for the registry" do
      test = @ichnaea.build_nerve_json('test', 'zk01', @app['app'], @app['app']['tasks'].first)
      test.must_equal @registry
    end
  end
end