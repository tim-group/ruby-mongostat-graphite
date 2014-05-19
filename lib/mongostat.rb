#!/usr/bin/ruby
module Mongostat
  require 'mongostat/parser'
  require 'mongostat/publisher'
  require 'mongostat/graphite_publisher'
  require 'mongostat/control_loop'
end

if caller() == []
  parser = Mongostat::Parser.new({:publisher => Mongostat::Publisher.new})
  control_loop = Mongostat::ControlLoop.new("/usr/bin/mongostat", parser)
  control_loop.start()
end

