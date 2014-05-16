require 'rubygems'
require 'mongostat'

class Mongostat::Parser
  attr_reader :headers
  @headers = {}

  def read_input(&block)
    ARGF.each_line do |line|
      parse(line, &block)
    end
  end

  def parse(line, &block)
    if !(line =~ /^connected/)
      if line =~ /^[a-zA-Z]/
        set_headers_from line
      else
        filtered_lines = filter(get_data_from(line))
        block.call(filtered_lines) if block
      end
    end
  end

  def filter(data)
    data
  end

  def replace_special_headers(headers)
    replacements_patterns.inject(headers) { |headers, (pattern, replacement)|
      headers.gsub! pattern, replacement
      headers
    }
  end

  def set_headers_from(line)
    header_line = replace_special_headers(line)
    new_headers = header_line.split(/\s|\|/).select{|part| part.length > 0}
    @headers = new_headers.select { |part| part =~ /^[a-z]|[A-Z]/}
  end

  def get_data_from(line)
    data = line.split(/\s|\|/).select{|part| part.length > 0}
    data.select { |part| part.gsub(/\s+/, "") =~ /^[0-9]/}
    @headers.zip(data).inject({}) { |hash, entry|  hash[entry[0]] = entry[1]; hash}
  end

  def replacements_patterns
    patterns = {}
    patterns[/idx miss %/] = 'idx_miss_percentage'
    patterns[/locked %/] = 'locked_percentage'
    patterns
  end

end


