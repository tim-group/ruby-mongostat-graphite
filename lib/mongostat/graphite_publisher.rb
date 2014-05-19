#!/usr/bin/ruby

require 'rubygems'
require 'graphite/logger'
require 'mongostat'

class Mongostat::GraphitePublisher
  attr_reader :filter_metrics

  def initialize(args={})
    @filter_metrics = %w(locked_percentage insert query update delete faults ar aw qr qw idx_miss_percentage conn getmore command flushes)

    graphite_host = args[:graphite_host] || 'metrics'
    @logger = args[:logger] || Graphite::Logger.new(graphite_host)
  end

  def publish(data)

    filtered_data = data.select { |metric, value| @filter_metrics.include?(metric.to_s) }
    @logger.log(Time.now.to_i, filtered_data) if @logger and !filtered_data.nil?

  end

end

