module Mongostat
  require 'mongostat/parser'
  require 'mongostat/publisher'
  require 'mongostat/graphite_publisher'
end

if caller() == []
  Mongostat::Parser.new.read_input
end

