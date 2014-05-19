#!/usr/bin/ruby

require 'rubygems'
require 'mongostat'

class Mongostat::Stdoutput
  def log (time, data)
    puts "{#{data.sort.map {|key,value| "#{key}:#{value}" }.join(',')}}"
  end
end

class Mongostat::Publisher

  def initialize(args={})
    @output = args[:output] || Mongostat::Stdoutput.new
  end

  def publish(data)
    @output.log(Time.now.to_i, data) if @output and !data.nil?
  end
end

