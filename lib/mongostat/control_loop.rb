require 'rubygems'
require 'mongostat'
require 'pty'

class Mongostat::ControlLoop
  def initialize(cmd, parser)
    @cmd = cmd
    @parser = parser
  end

  def start()

    begin
      PTY.spawn( @cmd ) do |stdin, stdout, pid|
        begin
          stdin.each do |line|
            @parser.parse_and_publish(line)
          end
        rescue Errno::EIO
          puts "Errno:EIO error, but this probably just means " +
            "that the process has finished giving output"
        end
      end
    rescue PTY::ChildExited
      raise "The child process exited!"
    end
  end
end

