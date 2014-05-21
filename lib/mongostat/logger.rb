require 'mongostat/namespace'

class Mongostat::Logger
  def initialize(args={})
    log_level = args[:log_level] || Syslog::LOG_WARNING
    @syslog = Syslog.open('mongostat', Syslog::LOG_CONS, Syslog::LOG_INFO)
    @syslog.mask = Syslog::LOG_UPTO(log_level)
  end

  def log(line)
     info(line)
  end

  def info(line)
     @syslog.log(Syslog::LOG_INFO, line)
  end

  def warn(line)
     @syslog.log(Syslog::LOG_WARNING)
  end

  def debug(line)
     @syslog.log(Syslog::LOG_DEBUG)
  end
end

