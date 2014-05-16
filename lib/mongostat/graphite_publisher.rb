#!/usr/bin/ruby

require 'rubygems'
require 'graphite/logger'
require 'mongostat'

class Mongostat::GraphitePublisher < Mongostat::Publisher
  attr_reader :filter_metrics

  def initialize(args={})
    @filter_metrics = ["locked_percentage", "insert", "query", "update", "delete", "faults","ar", "aw", "qr", "qw", "idx_miss_percentage", "conn", "getmore", "command", "flushes"]

    graphite_host = args[:graphite_host] || 'metrics'
    @logger = args[:logger] || Graphite::Logger.new(graphite_host)
  end

  def filter(data)
     data.select { |metric, value| @filter_metrics.include?(metric.to_s) }
  end

end

if caller() == []
  Mongostat::GraphitePublisher.new.parse_and_log
end


