require 'rubygems'
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

  it 'should read header from stdin input' do
    run_attempt = @test.run_via_cli('mongostat_fixture')
    run_attempt.should include "insert"
  end

end

