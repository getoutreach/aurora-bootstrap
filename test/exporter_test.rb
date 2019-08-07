require 'test_helper'

class ExporterTest < Minitest::Test
  def setup
    @exporter = AuroraBootstrapper::Exporter.new( db_host: "localhost:3306",
                                                  db_user: "root",
                                                  db_pass: "root",
                                                   prefix: ,
                                            export_bucket: bukkit )
  end

  def test_database_names

  end

  def test_database_name_prefix

  end

  def test_export_calls_database
    mock = Minitest::Mock.new
    mock.expect :export!

    AuroraBootstrapper::Database.any_instance.stubs( :export! ).returns( true )
    
    assert @exporter.export!
  end
end