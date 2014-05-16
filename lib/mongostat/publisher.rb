#!/usr/bin/ruby

require 'rubygems'
require 'logger'
require 'mongostat/parser'

class Mongostat::StdoutLogger
  def log (time, data)
    data.each do |key, value|
      print "#{key}:#{value} "
    end
    print "\n"
  end
end

class Mongostat::Publisher

  def initialize(args={})
    @logger = args[:logger] || Mongostat::StdoutLogger.new
    @parser = Mongostat::Parser.new
  end

  def read_and_output
    @parser.read_input do |data|
      log_to_output filter data
    end
  end

  def process_and_output(line, &block)
      @parser.process_and_output(line, &block)
  end

  def filter(data)
    data
  end

  def log_to_output(data)
      @logger.log(Time.now.to_i, data.sort) if @logger and !data.nil?
  end

end

if caller() == []
  Mongostat::Publisher.new.read_and_output
end


