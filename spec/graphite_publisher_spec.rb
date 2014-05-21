require 'rubygems'
require 'mongostat/graphite_publisher'
$: << File.join(File.dirname(__FILE__),  "..", "files")

describe 'MongostatGraphitePublisher' do

  class MockGraphite
    attr_reader :metrics_received

    def initialize
      @metrics_received = nil
    end

    def log(time, measurements)
      @metrics_received = measurements.inject({}) { |hash, entry|  hash[entry[0]] = entry[1]; hash}
    end

  end

  it 'should return the headers for mongostat 2.0.9' do
    graphite = MockGraphite.new
    publisher = Mongostat::GraphitePublisher.new({:graphite => graphite})

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
    data['command_local'] = '6'
    data['master'] = '1'
    data['query'] = '2'

    publisher.publish(data)

    require 'socket'
    hostname = Socket.gethostname
    metrics_received = graphite.metrics_received
    metrics_received["mongo.#{hostname}.locked_percentage"].should eql "9"
    metrics_received["mongo.#{hostname}.faults"].should eql "8"
    metrics_received["mongo.#{hostname}.qw"].should eql "12"
    metrics_received["mongo.#{hostname}.aw"].should eql "14"
    metrics_received["mongo.#{hostname}.qr"].should eql "11"
    metrics_received["mongo.#{hostname}.ar"].should eql "13"
    metrics_received["mongo.#{hostname}.query"].should eql "2"
    metrics_received["mongo.#{hostname}.insert"].should eql "1"
    metrics_received["mongo.#{hostname}.update"].should eql "3"
    metrics_received["mongo.#{hostname}.delete"].should eql "4"
    metrics_received["mongo.#{hostname}.idx_miss_percentage"].should eql "10"
    metrics_received["mongo.#{hostname}.conn"].should eql "100"
    metrics_received["mongo.#{hostname}.getmore"].should eql "5"
    metrics_received["mongo.#{hostname}.command_local"].should eql "6"
    metrics_received["mongo.#{hostname}.flushes"].should eql "7"
    metrics_received["mongo.#{hostname}.master"].should eql "1"

    metrics_received.has_key?("mongo.#{hostname}.netIn").should eql false
  end

end

