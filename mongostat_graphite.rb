#!/usr/bin/ruby

class MongostatGraphite
  @headers = ["insert",
              "query",
              "update",
              "delete",
              "getmore",
              "command",
              "flushes",
              "mapped",
              "vsize",
              "res",
              "faults",
              "lockedv",
              "idx",
              "miss",
              "qr|qw",
              "ar|aw",
              "netIn",
              "netOut",
              "conn",
              "time"]

  def read_input(&block)
    ARGF.each_line do |line|
      if !(line.start_with?("connected"))
        @headers = get_headers(line) if line =~ /^[a-zA-Z]/
        data = get_data(@headers, line)
        block.call(data) if block
      end
    end
  end

  def read_and_output_to_stdout
    read_input do |data|
       data.each {|key,val| puts "#{key}: #{val}"}
    end
  end

  def replace_special_headers(headers)
    headers.gsub! /idx miss %/, 'idx_miss_percentage'
    headers.gsub! /locked %/,   'locked_percentage'
    headers
  end

  def get_headers(line)
    header_line = replace_special_headers(line)
    headers = header_line.split(/\s|\|/).select{|part| part.length > 0}
    headers.select { |part| part =~ /^[a-z]|[A-Z]/}
  end

  def get_data(headers, line)
    results = []
    data = line.split(/\s|\|/).select{|part| part.length > 0}
    data.select { |part| part.gsub(/\s+/, "") =~ /^[0-9]/}
    headers.zip(data)
  end

end

if caller() == []
  MongostatGraphite.new.read_and_output_to_stdout
end

