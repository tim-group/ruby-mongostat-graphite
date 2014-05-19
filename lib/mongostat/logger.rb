class Mongostat::Logger
  def log(line)
      syslog = Syslog.open('mongostat', Syslog::LOG_CONS, Syslog::LOG_INFO)
      #syslog.mask = Syslog::LOG_UPTO(Syslog::LOG_INFO)
      syslog.log(Syslog::LOG_INFO, line.to_s)
      puts line
      syslog.close
  end
end

