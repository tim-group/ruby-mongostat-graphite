#!/usr/bin/ruby

require 'rubygems'
require 'mongostat'

class Mongostat::StdoutLogger
  def log (time, data)
    puts "{#{data.sort.map {|key,value| "#{key}:#{value}" }.join(',')}}"
    end
end

class Mongostat::Publisher < Mongostat::Parser

  def initialize(args={})
    @logger = args[:logger] || Mongostat::StdoutLogger.new
  end

  def parse_and_log
    read_input do |data|
      log data
    end
  end

  def log(data)
      @logger.log(Time.now.to_i, data.sort) if @logger and !data.nil?
  end

end

if caller() == []
  Mongostat::Publisher.new.parse_and_log
end


