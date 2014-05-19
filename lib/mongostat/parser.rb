require 'rubygems'
require 'mongostat'
require 'syslog'

class Mongostat::Parser
  attr_reader :headers
  @headers = {}
  @publisher = nil

  def initialize(args = {})
    @publisher = args[:publisher] || Mongostat::GraphitePublisher.new
  end

  def log(line)
      syslog = Syslog.open('mongostat', Syslog::LOG_CONS, Syslog::LOG_INFO)
      #syslog.mask = Syslog::LOG_UPTO(Syslog::LOG_INFO)
      syslog.log(Syslog::LOG_INFO, line.to_s)
      syslog.close
  end

  def parse_and_publish(line)

    if (line =~ /couldn't connect/)
      log "#{line}"
    elsif (line =~ /^[a-zA-Z]/)
      set_headers_from(line)
    elsif (line =~ /^\s+\d/)
      @publisher.publish(parsed_data_from(line))
    else
      log line
    end
  end

  def replace_special_headers(headers)
    replacements_patterns.inject(headers) { |all_headers, (pattern, replacement)|
      all_headers.gsub! pattern, replacement
      all_headers
    }
  end

  def set_headers_from(line)
    header_line = replace_special_headers(line)
    new_headers = header_line.split(/\s|\|/).select{|part| part.length > 0}
    @headers = new_headers.select { |part| part =~ /^[a-z]|[A-Z]/}
  end

  def parsed_data_from(line)
    data = line.split(/\s|\|/).select{|part| part.length > 0}
    data.select { |part| part.gsub(/\s+/, '') =~ /^[0-9]/}
    @headers.zip(data).inject({}) { |hash, (key, value)|  hash[key] = value; hash}
  end

  def replacements_patterns
    patterns = {}
    patterns[/idx miss %/] = 'idx_miss_percentage'
    patterns[/locked %/] = 'locked_percentage'
    patterns
  end

end

