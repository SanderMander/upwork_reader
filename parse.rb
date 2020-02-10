#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'http'
require 'time_difference'
require 'logstash-logger'
require 'pry-byebug'
require_relative 'lib/config.rb'
require_relative 'lib/parser.rb'
parser = Parser.new(Config.feeds)

while true do
  begin
    parser.parse_feeds
  rescue StandardError => e
    puts e.message
  end
  puts '*** next tick will be in 5 minutes ***'
  sleep Config.sleep_time.to_i
end
