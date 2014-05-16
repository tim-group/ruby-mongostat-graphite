require 'rubygems'
require 'mongostat_graphite'
$: << File.join(File.dirname(__FILE__),  "..", "files")

describe 'MongostatGraphitePublisher' do

  class MockGraphiteLogger < Graphite::Logger
    attr_reader :metrics_received

    def initialize
      @metrics_received = nil
    end

    def log(time, measurements)
      @metrics_received = measurements.inject({}) { |hash, entry|  hash[entry[0]] = entry[1]; hash}
    end

  end

  class MongostatGraphitePublisherTest

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
   @test = MongostatGraphitePublisherTest.new
  end

  it 'should return the headers for mongostat 2.0.9' do
    headers_209 = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'

    graphite_logger = MockGraphiteLogger.new
    publisher = Mongostat::GraphitePublisher.new({:graphite_logger => graphite_logger})

    [headers_209, test_data].each { |line|
      publisher.process_and_output(line) do |hash|
        publisher.output_to_graphite(hash)
      end
    }

    metrics_received = graphite_logger.metrics_received
    metrics_received["locked_percentage"].should eql "9"
    metrics_received["faults"].should eql "8"
    metrics_received["qw"].should eql "12"
    metrics_received["aw"].should eql "14"
    metrics_received["qr"].should eql "11"
    metrics_received["ar"].should eql "13"
    metrics_received["query"].should eql "2"
    metrics_received["insert"].should eql "1"
    metrics_received["update"].should eql "3"
    metrics_received["delete"].should eql "4"
    metrics_received["idx_miss_percentage"].should eql "10"
    metrics_received["conn"].should eql "100"
    metrics_received["getmore"].should eql "5"
    metrics_received["command"].should eql "6"
    metrics_received["flushes"].should eql "7"
  end

end

