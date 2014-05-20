require 'rubygems'
require 'mongostat'
require 'logger'
$: << File.join(File.dirname(__FILE__),  '..', 'mongostat', 'lib')

describe 'Mongostat' do

  it 'should output data to stdout with newlines by default' do
    class MockOutput
      attr_reader :metrics_received

      def initialize
        @metrics_received = {}
      end

      def log(time, measurements)
        @metrics_received = measurements.inject({}) { |hash, entry|  hash[entry[0]] = entry[1]; hash}
      end

      def size
        @metrics_received.size
      end

    end
    require 'socket'
    hostname = Socket.gethostname
    fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
    mock_output = MockOutput.new
    logger = Mongostat::Logger.new
    parser = Mongostat::Parser.new({
      :publisher => Mongostat::GraphitePublisher.new({:graphite => mock_output}),
    })
    control_loop = Mongostat::ControlLoop.new({
      :cmd          => "cat #{fixture_path}/mongostat_209_single_line; sleep 999", #never terminate
      :parser       => parser,
      :logger       => logger,
    })
    Thread.new {
      control_loop.start
    }
    sleep 0.5 # wait to mock output to receive stdin
    metrics_received = mock_output.metrics_received
    metrics_received["mongo.#{hostname}.locked_percentage"].should eql "1"
    metrics_received["mongo.#{hostname}.qw"].should eql "2"
    metrics_received["mongo.#{hostname}.idx_miss_percentage"].should eql "5"
    metrics_received["mongo.#{hostname}.flushes"].should eql "7"
    metrics_received.has_key?("mongo.#{hostname}.netIn").should eql false
    control_loop.stop
  end
end

