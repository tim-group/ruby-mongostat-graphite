#!/usr/bin/ruby

require 'rubygems'
require 'graphite/logger'

class Mongostat
  attr_reader :headers
  @headers = {}

  def read_input(&block)
    ARGF.each_line do |line|
      process_and_output(line, &block)
    end
  end

  def process_and_output(line, &block)
    if !(line =~ /^connected/)
      if line =~ /^[a-zA-Z]/
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
    replacements_patterns.inject(headers) { |headers, (pattern, replacement)|
      headers.gsub! pattern, replacement
      headers
    }
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

  def replacements_patterns
    patterns = {}
    patterns[/idx miss %/] = 'idx_miss_percentage'
    patterns[/locked %/] = 'locked_percentage'
    patterns
  end

end

if caller() == []
  Mongostat.new.read_and_output_to_stdout
end

