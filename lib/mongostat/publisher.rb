#!/usr/bin/ruby

require 'rubygems'
require 'mongostat'

class Mongostat::StdoutLogger
  def log (time, data)
    puts "{#{data.sort.map {|key,value| "#{key}:#{value}" }.join(',')}}"
  end
end

class Mongostat::Publisher

  def initialize(args={})
    @logger = args[:logger] || Mongostat::StdoutLogger.new
  end

  def publish(data)
    #data.each {|key,value| puts "'#{key}' -> '#{value}',"}
    #puts "{#{data.sort.map {|key,value| "#{key}:#{value}" }.join(',')}}"
    @logger.log(Time.now.to_i, data) if @logger and !data.nil?
  end
end

if caller() == []
  publisher = Mongostat::Publisher.new
  Mongostat::Parser.new({:publisher => publisher}).read_input
end



