require 'rubygems'
require 'mongostat'
require 'logger'
$: << File.join(File.dirname(__FILE__),  '..', 'mongostat', 'lib')

describe 'Mongostat' do

  it 'should output data to stdout with newlines by default for unclustered servers' do
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
    logger = Logger.new(STDOUT)
    logger.level = Logger::FATAL
    parser = Mongostat::Parser.new({
      :publisher => Mongostat::GraphitePublisher.new({:graphite => mock_output}),
    })
    control_loop = Mongostat::ControlLoop.new({
      :cmd          => "cat #{fixture_path}/mongostat_209_unclustered_single_line; sleep 999", #never terminate
      :parser       => parser,
      :logger       => logger,
    })
    Thread.new {
      control_loop.start
    }
    sleep 0.5 # wait to mock output to receive stdin
    metrics_received = mock_output.metrics_received
    metrics_received["mongo.#{hostname}.insert"].should eql "0"
    metrics_received["mongo.#{hostname}.query"].should eql "1"
    metrics_received["mongo.#{hostname}.update"].should eql "2"
    metrics_received["mongo.#{hostname}.delete"].should eql "3"
    metrics_received["mongo.#{hostname}.getmore"].should eql "4"
    metrics_received["mongo.#{hostname}.command_local"].should eql "5"
    metrics_received["mongo.#{hostname}.flushes"].should eql "6"
    metrics_received["mongo.#{hostname}.faults"].should eql "7"
    metrics_received["mongo.#{hostname}.locked_percentage"].should eql "8"
    metrics_received["mongo.#{hostname}.idx_miss_percentage"].should eql "9"
    metrics_received["mongo.#{hostname}.qr"].should eql "10"
    metrics_received["mongo.#{hostname}.qw"].should eql "11"
    metrics_received["mongo.#{hostname}.ar"].should eql "12"
    metrics_received["mongo.#{hostname}.aw"].should eql "13"
    metrics_received["mongo.#{hostname}.conn"].should eql "14"
    metrics_received.has_key?("mongo.#{hostname}.netIn").should eql false
    metrics_received.has_key?("mongo.#{hostname}.netOut").should eql false
    metrics_received.has_key?("mongo.#{hostname}.vsize").should eql false
    metrics_received.has_key?("mongo.#{hostname}.res").should eql false
    metrics_received.has_key?("mongo.#{hostname}.mapped").should eql false
    control_loop.stop
  end

  it 'should output data to stdout with newlines by default for clusters master servers' do
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
    logger = Logger.new(STDOUT)
    logger.level = Logger::FATAL
    parser = Mongostat::Parser.new({
      :publisher => Mongostat::GraphitePublisher.new({:graphite => mock_output}),
    })
    control_loop = Mongostat::ControlLoop.new({
      :cmd          => "cat #{fixture_path}/mongostat_209_clustered_master_single_line; sleep 999", #never terminate
      :parser       => parser,
      :logger       => logger,
    })
    Thread.new {
      control_loop.start
    }
    sleep 0.5 # wait to mock output to receive stdin
    metrics_received = mock_output.metrics_received
    metrics_received["mongo.#{hostname}.insert"].should eql "0"
    metrics_received["mongo.#{hostname}.query"].should eql "509"
    metrics_received["mongo.#{hostname}.update"].should eql "59"
    metrics_received["mongo.#{hostname}.delete"].should eql "0"
    metrics_received["mongo.#{hostname}.getmore"].should eql "1"
    metrics_received["mongo.#{hostname}.command_local"].should eql "120"
    metrics_received["mongo.#{hostname}.flushes"].should eql "0"
    metrics_received["mongo.#{hostname}.faults"].should eql "0"
    metrics_received["mongo.#{hostname}.locked_percentage"].should eql "2.1"
    metrics_received["mongo.#{hostname}.idx_miss_percentage"].should eql "0"
    metrics_received["mongo.#{hostname}.qr"].should eql "0"
    metrics_received["mongo.#{hostname}.qw"].should eql "0"
    metrics_received["mongo.#{hostname}.ar"].should eql "1"
    metrics_received["mongo.#{hostname}.aw"].should eql "0"
    metrics_received["mongo.#{hostname}.conn"].should eql "210"
    metrics_received["mongo.#{hostname}.master"].should eql "1"
    metrics_received.has_key?("mongo.#{hostname}.netIn").should eql false
    metrics_received.has_key?("mongo.#{hostname}.netOut").should eql false
    metrics_received.has_key?("mongo.#{hostname}.vsize").should eql false
    metrics_received.has_key?("mongo.#{hostname}.res").should eql false
    metrics_received.has_key?("mongo.#{hostname}.mapped").should eql false
    control_loop.stop
  end
end

