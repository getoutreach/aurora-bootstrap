require 'test_helper'

class CsvParserTest < Minitest::Test
  def setup
    @parser = AuroraBootstrapper::CsvParser.new bucket: "local-bucket", table: "my-database/local-events", client: Gls::S2.new
  end

  def test_manifest_json
    assert_equal( {"entries"=>[{"url"=>"local://local-bucket/my-database/events.part_00000"}, {"url"=>"local://local-bucket/my-database/events.part_00001"}]}, @parser.manifest_json )
  end

  def test_parts
    assert_equal [{ bucket: "local-bucket", file_name: "my-database/events.part_00000", csv_chunk_size: 10 },
                  { bucket: "local-bucket", file_name: "my-database/events.part_00001", csv_chunk_size: 10 }], @parser.parts.map( &:to_h )
  end

  def test_fields
    assert_equal ["id", "user_id", "prospect_id", "name", "uniq", "created_at", "message_id", "event_at", "request_host", "request_ip", "request_lat", "request_long", "request_city", "request_region", "request_proxied", "request_device", "actor_id", "actor_type", "account_id", "task_id", "note_id", "stage_id", "mailing_id", "template_id", "sequence_id", "sequence_template_id", "sequence_step_id", "mailbox_id", "schedule_id", "plugin_id", "plugin_type_mapping_id", "plugin_field_mapping_id", "import_id", "team_id", "team_membership_id", "trigger_id", "user2_id", "payload", "sequence_state_id", "call_id", "opportunity_id", "opportunity_stage_id", "opportunity_prospect_role_id", "ruleset_id", "phone_number_id", "contact_id", "snippet_id", "calendar_event_id", "calendar_id"], @parser.fields
  end

  def test_hasherize
    @parser.stubs( :fields ).returns( ["id", "event_name"] )

    # remainder tests
    assert_equal [ [], "a" ], @parser.hasherize( chunk: "a" )
    assert_equal [ [], "ba" ], @parser.hasherize( chunk: "a", remainder: "b" )

    # record with no row delimiter at the end
    assert_equal [ [ { "id" => "1", "event_name" => "lol" } ], "" ],
                  @parser.hasherize( chunk: "1#{AuroraBootstrapper::COL_DELIMITER}lol" )

    # record with row delimiter at the end
    assert_equal [ [ { "id" => "1", "event_name" => "lol" } ], "" ],
                  @parser.hasherize( chunk: "1#{AuroraBootstrapper::COL_DELIMITER}lol#{AuroraBootstrapper::ROW_DELIMITER}" )

    # record with row delimiter at the beginning
    assert_equal [ [ { "id" => "1", "event_name" => "lol" } ], "" ],
                  @parser.hasherize( chunk: "#{AuroraBootstrapper::ROW_DELIMITER}1#{AuroraBootstrapper::COL_DELIMITER}lol" )

    # record with row delimiter at the beginning
    assert_equal [ [ { "id" => "1", "event_name" => "lol" },
                     { "id" => "2", "event_name" => "wat" } ], "" ],
                  @parser.hasherize( chunk: "lol#{AuroraBootstrapper::ROW_DELIMITER}2#{AuroraBootstrapper::COL_DELIMITER}wat", remainder: "1#{AuroraBootstrapper::COL_DELIMITER}" )

    # payload complete with remainder
    assert_equal [ [ { "id" => "1", "event_name" => "lol" } ], "4" ],
                  @parser.hasherize( chunk: "1#{AuroraBootstrapper::COL_DELIMITER}lol#{AuroraBootstrapper::ROW_DELIMITER}4" )

    # record split across payloads
    assert_equal [ [ { "id" => "1", "event_name" => "lol" } ], "4" ],
                  @parser.hasherize( chunk: "#{AuroraBootstrapper::COL_DELIMITER}lol#{AuroraBootstrapper::ROW_DELIMITER}4", remainder: "1" )

    # record split in the middle of the delimiter
    assert_equal [ [ { "id" => "1", "event_name" => "lol" } ], "4" ],
                  @parser.hasherize( chunk: "#{AuroraBootstrapper::COL_DELIMITER[11..-1]}lol#{AuroraBootstrapper::ROW_DELIMITER}4", remainder: "1#{AuroraBootstrapper::COL_DELIMITER[0..10]}" )
  end

  def test_header_row
    @parser.stubs( :fields ).returns( ["id", "event_name"] )
    assert @parser.header_row?( [ "id", "event_name" ] )
    refute @parser.header_row?( [ "6", "event_name" ] )
    refute @parser.header_row?( [ "6" ] )
    refute @parser.header_row?( [ "event_name" ] )

    chunk = "id#{AuroraBootstrapper::COL_DELIMITER}event_name#{AuroraBootstrapper::ROW_DELIMITER}1#{AuroraBootstrapper::COL_DELIMITER}failboat"

    assert_equal 1, @parser.hasherize( chunk: chunk ).first.count
    assert_equal [ { "id" => "1", "event_name" => "failboat" } ], @parser.hasherize( chunk: chunk ).first
  end

  def test_read
    rows = []
    @parser.read do |chunk|
      rows += chunk
      assert_equal 14, chunk.count
      assert_equal @parser.fields, chunk.first.keys
    end

    assert_equal 28, rows.count
  end

  def test_read_across_file_chunks
    @parser = AuroraBootstrapper::CsvParser.new bucket: "local-bucket", table: "my-database/local-events", client: Gls::S2.new, csv_chunk_size: 0.01
    
    rows = []
    @parser.read do |chunk|
      rows += chunk
    end

    assert_equal @parser.fields, rows.first.keys
    assert_equal 28, rows.count

    # let's see if this works if the chunks are narrower than row sizes

    @parser = AuroraBootstrapper::CsvParser.new bucket: "local-bucket", table: "my-database/local-events", client: Gls::S2.new, csv_chunk_size: 0.001
    
    rows = []
    @parser.read do |chunk|
      rows += chunk
    end

    assert_equal @parser.fields, rows.first.keys
    assert_equal 28, rows.count
  end
end