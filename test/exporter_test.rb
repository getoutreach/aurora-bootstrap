require 'test_helper'

class ExporterTest < Minitest::Test
  def setup
    @db_user  = ENV.fetch "DB_USER"
    @db_pass  = ENV.fetch "DB_PASS"
    @db_host  = ENV.fetch "DB_HOST"
    @prefix   = ENV.fetch "PREFIX", ""
    @bukkit   = ENV.fetch "EXPORT_BUCKET"

    @exporter = AuroraBootstrapper::Exporter.new( db_host: @db_host,
                                                  db_user: @db_user,
                                                  db_pass: @db_pass,
                                                   prefix: @prefix,
                                            export_bucket: @bukkit )
  end

  def test_database_names
    assert_equal [ "user_properties", "user_stuff" ], @exporter.database_names
  end

  def test_database_name_prefix
    assert_equal [ "user_properties", "user_stuff" ], @exporter.database_names

    everything_exporter = AuroraBootstrapper::Exporter.new( db_host: @db_host,
                                                            db_user: @db_user,
                                                            db_pass: @db_pass,
                                                             prefix: "",
                                                      export_bucket: @bukkit )

    assert_equal [ "information_schema", "master", "mysql", "performance_schema", "sys", "user_properties", "user_stuff" ], everything_exporter.database_names
  end

  def test_export_calls_database
    mock = Minitest::Mock.new
    mock.expect :export!, nil

    AuroraBootstrapper::Database.any_instance.stubs( :export! ).returns( true )
    
    assert @exporter.export!
  end
end