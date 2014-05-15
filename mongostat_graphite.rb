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

  def read_input
   ARGF.each_line { |line|
     if !(line.start_with?("connected"))
       headers = get_headers(line)
       data = get_data(headers, line)
     end

   }
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
  MongostatGraphite.new.read_input
end

