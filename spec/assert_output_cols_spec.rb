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
   @mongo_stat = MongostatGraphite.new
  end

  after do
  end

  it 'should output data to stdout with newlines by default' do
    @test.run_via_cli('mongostat_209_single_line').should eql "{ar:0,aw:0,command:1,conn:1,delete:0,faults:0,flushes:0,getmore:0,idx_miss_percentage:0,insert:0,locked_percentage:0,mapped:16.2g,netIn:62b,netOut:1k,qr:0,query:0,qw:0,res:2m,time:16:01:49,update:0,vsize:34.1g}\n"
  end

  it 'should return the headers for mongostat 2.0.9' do
    headers_209 = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    @mongo_stat.set_headers_from(headers_209)
    @mongo_stat.headers.should eql ["insert", "query", "update", "delete", "getmore", "command", "flushes", "mapped", "vsize", "res", "faults", "locked_percentage", "idx_miss_percentage", "qr", "qw", "ar", "aw", "netIn", "netOut", "conn", "time"]
  end

  it 'should rename special headers' do
    headers = "insert locked % idx miss %"
    @mongo_stat.replace_special_headers(headers).should eql "insert locked_percentage idx_miss_percentage"
  end

  it 'should return the data' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    @mongo_stat.set_headers_from(test_headers)
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'
    symbol_hash = @mongo_stat.get_data_from(test_data).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    symbol_hash.should eql (
      {
      :vsize => "34.1g",
      :netIn=>"62b",
      :command=>"6",
      :getmore=>"5",
      :time=>"16:01:49",
      :res=>"2m",
      :conn=>"100",
      :netOut=>"1k",
      :insert=>"1",
      :qw=>"12",
      :qr=>"11",
      :locked_percentage=>"9",
      :update=>"3",
      :query=>"2",
      :aw=>"14",
      :ar=>"13",
      :idx_miss_percentage=>"10",
      :faults=>"8",
      :mapped=>"16.2g",
      :delete=>"4",
      :flushes=>"7"
     })
  end
end

