require 'rubygems'
require 'mongostat_graphite'
$: << File.join(File.dirname(__FILE__),  "..", "files")

describe 'AssertOutputColsTest' do

  class AssertOutputColsTest

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
   @test = AssertOutputColsTest.new
  end

  after do
  end

  xit 'should read header from stdin input' do
    run_attempt = @test.run_via_cli('mongostat_fixture')
    run_attempt.should include "insert"
  end

  it 'should return the headers' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    MongostatGraphite.new.get_headers(test_headers).should eql ["insert", "query", "update", "delete", "getmore", "command", "flushes", "mapped", "vsize", "res", "faults", "locked", "idx", "miss", "qr|qw", "ar|aw", "netIn", "netOut", "conn", "time"]
  end

  it 'should return the data' do
    headers = ["insert", "query", "update", "delete", "getmore", "command", "flushes", "mapped", "vsize", "res", "faults", "locked", "idx", "miss", "qr|qw", "ar|aw", "netIn", "netOut", "conn", "time"]
    test_data = '#0      0      0      0       0       1       0  16.2g  34.1g     2m      0        0          0       0|0     0|0    62b     1k     1   16:01:49'
    MongostatGraphite.new.get_data(headers, test_data).should include ["query", "0"]
  end
end

