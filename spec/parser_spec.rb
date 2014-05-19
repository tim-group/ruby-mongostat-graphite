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

  it 'should return the data' do
    test_headers = 'insert  query update delete getmore command flushes mapped  vsize    res faults locked % idx miss %     qr|qw   ar|aw  netIn netOut  conn       time '
    @parser.set_headers_from(test_headers)
    test_data = '1      2      3      4       5       6       7  16.2g  34.1g     2m      8        9          10       11|12     13|14    62b     1k     100   16:01:49'
    symbol_hash = @parser.parsed_data_from(test_data).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

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

