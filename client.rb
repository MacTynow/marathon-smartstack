require "em-eventsource"

EM.run do
  # This shit doesn't resolve my DNS ZOMG
  source = EventMachine::EventSource.new("http://#{ENV.fetch('MARATHON')}:8080/v2/events",
                                        {query: 'text/event-stream'},
                                        {'Accept' => 'text/event-stream'})
  # source.use EM::Middleware::JSONResponse
  source.inactivity_timeout = 0

  puts "listening on http://#{ENV.fetch('MARATHON')}:8080/v2/events"

  source.open do
    puts "Stream opened with status #{source.ready_state}"
  end

  # This is to listen on all event types. Pretty heavy.
  # source.message do |message|
  #   puts "new message #{message}"
  # end

  source.on "app_terminated_event" do |message|
    puts "app_terminated_event #{message}"
  end

  source.error do |error|
    puts "error #{error}"
  end

  source.start # Start listening
end