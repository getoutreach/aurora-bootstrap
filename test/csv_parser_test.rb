require 'test_helper'

class CsvParserTest < Minitest::Test
  def setup
    @parser = AuroraBootstrapper::CsvParser.new bucket: "local-bucket", table: "local-events", client: Gls::S2.new
  end

  def test_manifest_json
    assert_equal( {"entries"=>[{"url"=>"local://local-bucket/database/events.part_00000"}]}, @parser.manifest_json )
  end

  def test_parts
    assert_equal [{ bucket: "local-bucket", file: "database/events.part_00000"}], @parser.parts
  end

  def test_fields
    assert_equal ["id", "user_id", "prospect_id", "name", "uniq", "created_at", "message_id", "event_at", "request_host", "request_ip", "request_lat", "request_long", "request_city", "request_region", "request_proxied", "request_device", "actor_id", "actor_type", "account_id", "task_id", "note_id", "stage_id", "mailing_id", "template_id", "sequence_id", "sequence_template_id", "sequence_step_id", "mailbox_id", "schedule_id", "plugin_id", "plugin_type_mapping_id", "plugin_field_mapping_id", "import_id", "team_id", "team_membership_id", "trigger_id", "user2_id", "payload", "sequence_state_id", "call_id", "opportunity_id", "opportunity_stage_id", "opportunity_prospect_role_id", "ruleset_id", "phone_number_id", "contact_id", "snippet_id", "calendar_event_id", "calendar_id"], @parser.fields
  end

  def test_hasherize

  end

  def test_read

  end
end