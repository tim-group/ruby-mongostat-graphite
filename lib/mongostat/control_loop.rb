require 'rubygems'
require 'mongostat/namespace'
require 'mongostat'
require 'pty'

class Mongostat::ControlLoop
  attr_reader :pid
  def initialize(args = {})
    @cmd = args[:cmd]
    @parser = args[:parser]
    @logger = args[:logger]
    @pid = nil
  end

  def start()

    begin
      @pid = PTY.spawn( @cmd ) do |stdin, stdout|
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

  def stop()
    Process.kill(9, @pid) if !@pid.nil?
  end

end

