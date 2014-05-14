#!/usr/bin/ruby

class MongostatGraphite

  def read_input
   ARGF.each_line { |line| puts line }
  end

end

if caller() == []
  MongostatGraphite.new.read_input
end

