require 'test_helper'

class TableTest < Minitest::Test
  def setup
    @db_user   = ENV.fetch "DB_USER"
    @db_pass   = ENV.fetch "DB_PASS"
    @db_host   = ENV.fetch "DB_HOST"
    @prefix    = ENV.fetch "PREFIX", ""
    @bukkit    = ENV.fetch "EXPORT_BUCKET"
    @blacklist = ENV.fetch "BLACKLISTED_TABLES", ""

    @exporter  = AuroraBootstrapper::Exporter.new( db_host: @db_host,
                                                   db_user: @db_user,
                                                   db_pass: @db_pass,
                                                    prefix: @prefix,
                                             export_bucket: @bukkit,
                                        blacklisted_tables: @blacklist )
    @client    = @exporter.client
    @table     = AuroraBootstrapper::Table.new database_name: "master",
                                                  table_name: "users",
                                                      client: @client
  end

  def test_fields
    assert_equal [ "id", "email", "first_name", "last_name" ], @table.fields
  end

  def test_fields_row
    assert_equal "'id', 'email', 'first_name', 'last_name'", @table.fields_row
  end

  def test_export_statement
    expected = <<~SQL
      SELECT 'id', 'email', 'first_name', 'last_name'
        UNION ALL
      SELECT id, email, first_name, last_name
        FROM master.users
      INTO OUTFILE S3 's3://bukkit/master/users'
        FIELDS TERMINATED BY 'AURORA-BOOTSTRAP-EXPORT-COL-DELIMITER'
        LINES TERMINATED BY 'AURORA-BOOTSTRAP-EXPORT-ROW-DELIMITER'
        MANIFEST ON
        OVERWRITE ON
    SQL
    assert_equal expected, @table.export_statement( into_bucket: "s3://bukkit")
  end

  def test_export_logs
    old_logger = AuroraBootstrapper.logger
    AuroraBootstrapper.logger = PutsLogger.new

    assert_output /Export failed:/ do
      @table.export!( into_bucket: "s3://bukkit")
    end

    mock = Minitest::Mock.new
    mock.expect :export!, nil

    @client.stubs( :query ).returns( "yay" )
    
    assert_output /Export succeeded: / do
      assert @table.export!( into_bucket: "s3://bukkit")
    end
    AuroraBootstrapper.logger = old_logger
  end

  def test_export
    AuroraBootstrapper::Table.any_instance.stubs( :export_statement ).returns( "select 'hurrah'" )

    assert @exporter.export!
  end
end