#!/usr/bin/ruby
module Mongostat
  require 'mongostat/parser'
  require 'mongostat/publisher'
  require 'mongostat/graphite_publisher'
  require 'mongostat/control_loop'
  require 'mongostat/logger'
end

if caller() == []
  logger = Mongostat::Logger.new
  parser = Mongostat::Parser.new({
    :publisher => Mongostat::GraphitePublisher.new,
    :logger    => logger
  })
  control_loop = Mongostat::ControlLoop.new({
    :cmd    => "/usr/bin/mongostat",
    :parser => parser,
    :logger => logger
  })
  control_loop.start()
end

