#!/usr/bin/ruby

require 'rubygems'
require 'graphite/logger'

class Mongostat
  attr_reader :headers, :graphite_metrics
  @headers = {}
  @graphite_metrics = ["locked_percentage"]
  #["insert", "query", "update", "delete", "getmore", "command", "flushes",
  #            "mapped", "vsize", "res", "faults", "lockedv", "idx", "miss", "qr|qw", "ar|aw",
  #            "netIn", "netOut", "conn", "time"]

  def read_input(&block)
    ARGF.each_line do |line|
      if line =~ /^connected/
        # ignore
      elsif line =~ /^[a-zA-Z]/
        set_headers_from line
      else
        block.call(get_data_from(line)) if block
      end
    end
  end

  def read_and_output_to_stdout
    read_input do |data|
      puts "{#{data.sort.map {|key,value| "#{key}:#{value}" }.join(',')}}"
    end
  end

  def replace_special_headers(headers)
    headers.gsub! /idx miss %/, 'idx_miss_percentage'
    headers.gsub! /locked %/,   'locked_percentage'
    headers
  end

  def set_headers_from(line)
    header_line = replace_special_headers(line)
    new_headers = header_line.split(/\s|\|/).select{|part| part.length > 0}
    @headers = new_headers.select { |part| part =~ /^[a-z]|[A-Z]/}
  end

  def get_data_from(line)
    data = line.split(/\s|\|/).select{|part| part.length > 0}
    data.select { |part| part.gsub(/\s+/, "") =~ /^[0-9]/}
    @headers.zip(data).inject({}) { |hash, entry|  hash[entry[0]] = entry[1]; hash}
  end

end

if caller() == []
  Mongostat.new.read_and_output_to_stdout
end

