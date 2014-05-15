#!/usr/bin/ruby

class MongostatGraphite

  def read_input
   ARGF.each_line { |line|
     if !(line.start_with?("connected"))
       columns = line.split(/\s/).select{|part| part.length > 0}
       headers = columns.select { |part| part =~ /^[a-z]|[A-Z]/}
       headers.each { |header| puts header }

       data = columns.select { |part| part.gsub(/\s+/, "") =~ /^[0-9]/}

       data.each { |item| puts item }


     end

   }
  end

end

if caller() == []
  MongostatGraphite.new.read_input
end

