#!/usr/bin/ruby

require 'rubygems'
require 'graphite/logger'
require 'mongostat/publisher'
require 'logger'

class Mongostat::GraphitePublisher < Mongostat::Publisher
  attr_reader :graphite_metrics

  def initialize(args={})

    @graphite_metrics = ["locked_percentage", "insert", "query", "update", "delete", "faults",
                         "ar", "aw", "qr", "qw", "idx_miss_percentage", "conn", "getmore", "command", "flushes"]
    graphite_host = 'metrics'
    #graphite_port
    @logger = args[:logger] || Graphite::Logger.new(graphite_host)
    @parser = Mongostat::Parser.new
  end

  def filter(data)
     data.select { |metric, value| @graphite_metrics.include?(metric.to_s) }
  end

end

if caller() == []
  Mongostat::GraphitePublisher.new.read_and_output
end


