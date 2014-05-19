require 'rubygems'
require 'mongostat/graphite_publisher'
$: << File.join(File.dirname(__FILE__),  "..", "files")

describe 'MongostatGraphitePublisher' do

  class MockLogger
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
      script_filename = 'lib/mongostate/graphite_publisher.rb'
      @script_path = File.join(File.dirname(__FILE__), ".." )
      @fixture_path = File.join(File.dirname(__FILE__), "fixtures")
      @script = "/usr/bin/ruby #{@script_path}/#{script_filename}"
    end

    def run_via_cli(fixture_filename)
      `cd #{@script_path}/lib; cat #{@fixture_path}/#{fixture_filename} | #{@script}`
    end
  end

  before do
   @test = MongostatGraphitePublisherTest.new
  end

  it 'should return the headers for mongostat 2.0.9' do
    logger = MockLogger.new
    publisher = Mongostat::GraphitePublisher.new({:logger => logger})

    data = {}
    data['idx_miss_percentage'] = '10'
    data['faults'] = '8'
    data['qw'] = '12'
    data['qr'] = '11'
    data['delete'] = '4'
    data['insert'] = '1'
    data['getmore'] = '5'
    data['time'] = '16:01:49'
    data['mapped'] = '16.2g'
    data['flushes'] = '7'
    data['netIn'] = '62b'
    data['aw'] = '14'
    data['ar'] = '13'
    data['netOut'] = '1k'
    data['res'] = '2m'
    data['conn'] = '100'
    data['locked_percentage'] = '9'
    data['update'] = '3'
    data['vsize'] = '34.1g'
    data['command'] = '6'
    data['query'] = '2'

    publisher.publish(data)

    metrics_received = logger.metrics_received
    metrics_received['locked_percentage'].should eql '9'
    metrics_received['faults'].should eql '8'
    metrics_received['qw'].should eql '12'
    metrics_received['aw'].should eql '14'
    metrics_received['qr'].should eql '11'
    metrics_received['ar'].should eql '13'
    metrics_received['query'].should eql '2'
    metrics_received['insert'].should eql '1'
    metrics_received['update'].should eql '3'
    metrics_received['delete'].should eql '4'
    metrics_received['idx_miss_percentage'].should eql '10'
    metrics_received['conn'].should eql '100'
    metrics_received['getmore'].should eql '5'
    metrics_received['command'].should eql '6'
    metrics_received['flushes'].should eql '7'

    metrics_received.has_key?('netIn').should eql false
  end

end

