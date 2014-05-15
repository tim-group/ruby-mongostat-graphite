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
       columns = line.split(/\s/).select{|part| part.length > 0}
       new_headers = columns.select { |part| part =~ /^[a-z]|[A-Z]/}
       # @headers.each { |header| puts header }

       data = columns.select { |part| part.gsub(/\s+/, "") =~ /^[0-9]/}

       # data.each { |item| puts item }

       if (!data.empty?)

         @headers.zip(data).each { |key, value| puts "#{key}, #{value}" }

       end


     end

   }
  end

end

if caller() == []
  MongostatGraphite.new.read_input
end

