#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  puts File.dirname(__FILE__)
  t = Task.find_by_done(false)
  t.process if t
  
  sleep 1
end