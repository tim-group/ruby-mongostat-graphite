#!/usr/bin/ruby

require 'rubygems'
require 'graphite/logger'
require 'mongostat'
require 'logger'

class Mongostat_Graphite < Mongostat
  attr_reader :graphite_metrics

  def initialize(args={})
    @graphite_metrics = ["locked_percentage"]
    graphite_host = 'metrics'
    #graphite_port
    @graphite_logger = args[:graphite_logger] || Graphite::Logger.new(graphite_host)
  end

  def read_and_output_to_graphite
    read_input do |data|
      output_to_graphite data
    end
  end

  def output_to_graphite(data)
      filtered_metrics = data.select { |metric, value| @graphite_metrics.include?(metric.to_s) }
      @graphite_logger.log(Time.now.to_i, filtered_metrics) if @graphite_logger
  end

end

if caller() == []
  Mongostat_Graphite.new.read_and_output_to_graphite
end

