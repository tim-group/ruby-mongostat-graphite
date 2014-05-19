require 'rubygems'
require 'mongostat'
require 'pty'

class Mongostat::ControlLoop
  def initialize(args = {})
    @cmd = args[:cmd]
    @parser = args[:parser]
    @logger = args[:logger]
  end

  def start()

    begin
      PTY.spawn( @cmd ) do |stdin, stdout, pid|
        begin
          stdin.each do |line|
            @parser.parse_and_publish(line)
          end
        rescue Errno::EIO
          @logger.log "Errno:EIO error, but this probably just means " +
            "that the process has finished giving output"
        end
      end
    rescue PTY::ChildExited
      @logger.log "The child process exited!"
    end
  end
end

