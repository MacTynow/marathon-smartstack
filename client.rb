#!/usr/bin/ruby

require 'em-http'
require 'em-eventsource'
require 'json'
require 'em-http/middleware/json_response'
require 'yajl'

def parse(stream)
  stream.each_line do |line|
    puts line
    test = JSON.parse line
    puts test['slaveId']
    puts test['appId']
    puts test['host']
    puts test['ports']
    puts '====================================================================='
  end
end

def write_config(service, port)
  target = open('test.txt', 'w')
  target.write (service)
  target.write (port)
  target.write("\n")
  target.close
end

EM.run do
  source = EventMachine::EventSource.new("http://#{ENV.fetch('MARATHON')}:8080/v2/events")
  source.inactivity_timeout = 0
  source.retry = 1 

  source.message do |message|
    test = parse(message)
    # puts test['eventType']
    write_config(test['eventType'], test['id'])
    # puts "new message #{message}"
  end

  source.error do |error|
    puts "error #{error}"
  end

  source.start # Start listening
end