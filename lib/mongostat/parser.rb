require 'mongostat/namespace'
require 'mongostat'
require 'rubygems'
require 'syslog'

class Mongostat::Parser
  attr_accessor :headers

  def initialize(args = {})
    @publisher = args[:publisher] || Mongostat::GraphitePublisher.new
    @logger = args[:logger]
    @headers = {}
  end

  def parse_and_publish(line)
    case line
      when /couldn't connect/
        @logger.log(line)
      when /^[a-zA-Z]/
        set_headers_from(line)
      when /^\s+\*?\d/
        publish(parse_secondary_data(line))
      when /^\s+\d/;
        publish(parse_common_data(line))
      else
        @logger.log("Un-recognised line: #{line}")
    end
  end

  def publish(data)
    @publisher.publish(data)
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

  def inject_master_header_and_value(data)
    if @headers.include? 'repl'
      repl_index = @headers.index('repl')
      @headers.push 'master'
      if data[repl_index] =~ /M/
        data.push '1'
      else
        data.push '0'
      end
    end
    data
  end

  def split_command_header
    command_index = @headers.index('command')
    modified_headers = @headers.reject { |key| key == 'command' }
    modified_headers.insert(command_index, 'command_replicated')
    modified_headers.insert(command_index, 'command_local')
    @headers = modified_headers
  end

  def rename_command_header
    command_index = @headers.index('command')
    @headers[command_index] = 'command_local'
  end

  def strip_wildcard_symbol(line)
    line.gsub(/\*/,'')
  end

  def parse_secondary_data(line)
    split_command_header if @headers.include? 'command'
    strip_wildcard_symbol(line)
    parse_common_data(strip_wildcard_symbol(line))
  end

  def parse_master_data(line)
    rename_command_header if @headers.include? 'command'
    parse_common_data(line)
  end

  def parse_common_data(line)
    data = line.split(/\s|\|/).select{|part| part.length > 0}
    data.select { |part| part.gsub(/\s+/, '') =~ /^[0-9]/}
    data = inject_master_header_and_value(data)
    @headers.zip(data).inject({}) { |hash, (key, value)|  hash[key] = value; hash}
  end

  def replacements_patterns
    patterns = {}
    patterns[/idx miss %/] = 'idx_miss_percentage'
    patterns[/locked %/] = 'locked_percentage'
    patterns
  end

end

