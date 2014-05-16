require 'rubygems'
require 'mongostat'
require 'logger'
$: << File.join(File.dirname(__FILE__),  "..", "mongostat", "lib")

describe 'MongostatPublisher' do

  class MockLogger < Logger
    attr_reader :metrics_received

    def initialize
      @metrics_received = nil
    end

    def log(time, measurements)
      @metrics_received = measurements.inject({}) { |hash, entry|  hash[entry[0]] = entry[1]; hash}
    end

  end

  class MongostatPublisherTest

    def initialize()
      script_filename = 'lib/mongostat/publisher.rb'
      @script_path = File.join(File.dirname(__FILE__), ".." )
      @fixture_path = File.join(File.dirname(__FILE__), "fixtures")
      @script = "/usr/bin/ruby #{@script_path}/#{script_filename}"
    end

    def run_via_cli(fixture_filename)
      `cd #{@script_path}/lib; cat #{@fixture_path}/#{fixture_filename} | #{@script}`
    end
  end

  before do
   @test = MongostatPublisherTest.new
  end

  it 'should output data to stdout with newlines by default' do
    @test.run_via_cli('mongostat_209_single_line').should eql "ar:0 aw:0 command:1 conn:1 delete:0 faults:0 flushes:0 getmore:0 idx_miss_percentage:0 insert:0 locked_percentage:0 mapped:16.2g netIn:62b netOut:1k qr:0 query:0 qw:0 res:2m time:16:01:49 update:0 vsize:34.1g \n"
  end

  it 'should return the headers for mongostat 2.0.9' do
    headers_209 = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'

    stdout_logger = MockLogger.new
    publisher = Mongostat::Publisher.new({:logger => stdout_logger})

    [headers_209, test_data].each { |line|
      publisher.process_and_output(line) do |hash|
        publisher.log_to_output(hash)
      end
    }

    metrics_received = stdout_logger.metrics_received
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

