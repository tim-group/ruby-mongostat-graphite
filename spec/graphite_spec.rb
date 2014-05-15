require 'rubygems'
require 'mongostat_graphite'
$: << File.join(File.dirname(__FILE__),  "..", "files")

describe 'Mongostat_Graphite' do

  class MockGraphiteLogger < Graphite::Logger
    attr_reader :metrics_received


    def initialize
      @metrics_received = nil
    end

    def log(time, measurements)
      @metrics_received = measurements
    end

  end

  class Mongostat_Graphite_Test

    def initialize()
      script_filename = 'mongostat_graphite.rb'
      @script_path = File.join(File.dirname(__FILE__), "..")
      @fixture_path = File.join(File.dirname(__FILE__), "fixtures")
      @script = "/usr/bin/ruby #{@script_path}/#{script_filename}"
    end

    def run_via_cli(fixture_filename)
      `cd #{@script_path}; cat #{@fixture_path}/#{fixture_filename} | #{@script}`
    end
  end

  before do
   @test = Mongostat_Graphite_Test.new
   @mongo_stat = Mongostat_Graphite.new
  end

  after do
  end

  it 'should return the headers for mongostat 2.0.9' do
    @graphite_logger = MockGraphiteLogger.new
    @mongo_stat = Mongostat_Graphite.new({:graphite_logger => @graphite_logger})

    headers_209 = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    @mongo_stat.set_headers_from(headers_209)
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'
    data = @mongo_stat.get_data_from(test_data)
    @mongo_stat.output_to_graphite(data)
    @graphite_logger.metrics_received.should eql "hello"
  end

end

