require 'test_helper'

class DatabaseTest < Minitest::Test
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
  end

  def test_table_names
    database = AuroraBootstrapper::Database.new database_name: "master", client: @client, blacklisted_tables: []

    assert_equal [ "users", "websites" ], database.table_names
  end


  def test_globally_blacklisted_tables
    blacklist       = ["websites"]
    master_database = AuroraBootstrapper::Database.new database_name: "master", client: @client, blacklisted_tables: blacklist
    stuff_database  = AuroraBootstrapper::Database.new database_name: "user_stuff", client: @client, blacklisted_tables: blacklist

    assert_equal [ "users" ], master_database.table_names
    assert_equal [ "photos" ], stuff_database.table_names
  end

  def test_db_specific_blacklisted_tables
    blacklist           = ["master.websites", "user_properties.hypersensitive_data"]
    master_database     = AuroraBootstrapper::Database.new database_name: "master", client: @client, blacklisted_tables: blacklist
    properties_database = AuroraBootstrapper::Database.new database_name: "user_properties", client: @client, blacklisted_tables: blacklist
    stuff_database      = AuroraBootstrapper::Database.new database_name: "user_stuff", client: @client, blacklisted_tables: blacklist


    assert_equal [ "users" ], master_database.table_names
    assert_equal [ "photos", "websites" ], stuff_database.table_names
    assert_equal [ "avatars" ], properties_database.table_names
  end

  def test_export_calls_table
    mock = Minitest::Mock.new
    mock.expect :export!, nil

    AuroraBootstrapper::Table.any_instance.stubs( :export! ).returns( true )
    
    assert @exporter.export!
  end
end