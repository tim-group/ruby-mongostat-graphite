require 'mongostat/namespace'
require 'rubygems'
require 'graphite/logger'
require 'mongostat'
require 'socket'

class Mongostat::GraphitePublisher

  def initialize(args={})
    @filter_metrics = %w(locked_percentage insert query update delete faults ar aw qr qw idx_miss_percentage conn getmore command_replicated command_local master flushes)

    @logger = args[:logger]
    graphite_hostname = args[:graphite_hostname] || 'metrics'
    @graphite = args[:graphite] || Graphite::Logger.new(graphite_hostname, @logger)
  end

  def filter(data)
    data.select { |metric, value| @filter_metrics.include?(metric.to_s) }
  end

  def embed_hostname_in_keys(data, database)
    key = "mongo.#{Socket.gethostname}"
    key = "#{key}.#{database}" if !database.nil?
    data.inject({}) { |hash, (metric, value)| hash["#{key}.#{metric}"] = value; hash }
  end

  def publish(data)
    database = data[:database] if data.has_key?(:database)
    data_with_renamed_keys = embed_hostname_in_keys(filter(data), database)
    @graphite.log(Time.now.to_i, data_with_renamed_keys) if @graphite and !data_with_renamed_keys.nil?
  end

end

