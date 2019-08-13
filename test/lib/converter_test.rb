require 'test_helper'

class ConverterTest < Minitest::Test
  def setup
    Gls::S2.files_written = []
    @converter = AuroraBootstrapper::Converter.new( out_of_csv_bucket: "local-bucket",
                                                     into_json_bucket: "remote-bucket",
                                                               tables: "my-database.local-events,my-database.users",
                                                               client: Gls::S2.new )
  end

  def test_missing_table_logs_but_does_not_raise
    with_puts_logger do
      assert_output /my-database.users/ do
        @converter.convert!
      end
    end
    assert_equal [ "authenticated-read", "authenticated-read" ], Gls::S2.files_written.map{ |f| f[:acl] }
    assert_equal [ "remote-bucket", "remote-bucket" ], Gls::S2.files_written.map{ |f| f[:bucket] }
    assert_equal [ "my-database/local-events.0.json", "my-database/local-events.1.json" ], Gls::S2.files_written.map{ |f| f[:key] }
  end

  def test_conversion
    with_puts_logger do
      assert_output /Writing to remote-bucket\/my-database\/local-events.0.json/ do
        @converter.convert!
      end
    end
    
    parser = AuroraBootstrapper::CsvParser.new bucket: "local-bucket", table: "my-database/local-events", client: Gls::S2.new
    parsed_json = JSON.parse Gls::S2.files_written.first[:body]
    
    assert_equal 14, parsed_json.count
    assert_equal parser.fields, parsed_json.first.keys
    refute_equal parser.fields, parsed_json.first.values
  end
end

