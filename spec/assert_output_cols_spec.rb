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

  it 'should return the headers' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    MongostatGraphite.new.get_headers(test_headers).should eql ["insert", "query", "update", "delete", "getmore", "command", "flushes", "mapped", "vsize", "res", "faults", "locked_percentage", "idx_miss_percentage", "qr", "qw", "ar", "aw", "netIn", "netOut", "conn", "time"]
  end

  it 'should rename special headers' do
    headers = "insert locked % idx miss %"
    MongostatGraphite.new.replace_special_headers(headers).should eql "insert locked_percentage idx_miss_percentage"
  end

  it 'should return the data' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    headers = MongostatGraphite.new.get_headers(test_headers)
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'
    MongostatGraphite.new.get_data(headers, test_data).should eql [
      ["insert", "1"],
      ["query", "2"],
      ["update", "3"],
      ["delete", "4"],
      ["getmore", "5"],
      ["command", "6"],
      ["flushes", "7"],
      ["mapped", "16.2g"],
      ["vsize", "34.1g"],
      ["res", "2m"],
      ["faults", "8"],
      ["locked_percentage", "9"],
      ["idx_miss_percentage", "10"],
      ["qr", "11"],
      ["qw", "12"],
      ["ar", "13"],
      ["aw", "14"],
      ["netIn", "62b"],
      ["netOut", "1k"],
      ["conn", "100"],
      ["time", "16:01:49"]
    ]
  end
end

