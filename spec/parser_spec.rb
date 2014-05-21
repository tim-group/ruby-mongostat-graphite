require 'rubygems'
require 'mongostat'
$: << File.join(File.dirname(__FILE__),  "..", "mongostat", "lib")

describe 'Mongostat::Parser' do

  before do
   @parser = Mongostat::Parser.new
  end

  it 'should return the headers for mongostat 2.0.9' do
    headers_209 = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    @parser.set_headers_from(headers_209)
    @parser.headers.should eql ["insert", "query", "update", "delete", "getmore", "command", "flushes", "mapped", "vsize", "res", "faults", "locked_percentage", "idx_miss_percentage", "qr", "qw", "ar", "aw", "netIn", "netOut", "conn", "time"]
  end

  it 'should rename special headers' do
    headers = "insert locked % idx miss %"
    @parser.replace_special_headers(headers).should eql "insert locked_percentage idx_miss_percentage"
  end

  it 'should return the data for a secondary server' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn  set repl       time '
    @parser.set_headers_from(test_headers)
    test_data = '*34     *0   *177     *0       4     3|0       0   376g   753g  2.23g   3295        1          0       0|0     0|0   266b     3k     7 merc  SEC   15:04:04'

    symbol_hash = @parser.parse_secondary_data(test_data).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    symbol_hash.should eql(
      {
      :ar=>"0",
      :aw=>"0",
      :command_local=>"3",
      :command_replicated=>"0",
      :conn=>"7",
      :delete=>"0",
      :faults=>"3295",
      :flushes=>"0",
      :getmore=>"4",
      :idx_miss_percentage=>"0",
      :insert=>"34",
      :locked_percentage=>"1",
      :mapped=>"376g",
      :netIn=>"266b",
      :netOut=>"3k",
      :qr=>"0",
      :query=>"0",
      :qw=>"0",
      :res=>"2.23g",
      :set=>"merc",
      :repl=>"SEC",
      :time=>"15:04:04",
      :update=>"177",
      :vsize => "753g",
     })
  end

  it 'should return the data for a master server' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    @parser.set_headers_from(test_headers)
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'
    symbol_hash = @parser.parse_master_data(test_data).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    symbol_hash.should eql(
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

