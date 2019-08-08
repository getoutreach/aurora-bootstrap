module AuroraBootstrapper
  class Exporter
    attr_reader :client

    def initialize( db_host:, db_user:, db_pass:, prefix: "", export_bucket:, blacklisted_tables: "" )
      @db_host            = db_host
      @db_user            = db_user
      @db_pass            = db_pass
      @match              = "#{prefix}.*"
      @export_bucket      = export_bucket
      @blacklisted_tables = blacklisted_tables.split(",")
      @client  = Mysql2::Client.new(     host: db_host,
                                     username: db_user,
                                     password: db_pass)
    end

    def export!
      database_names.all? do | database_name |
        database = Database.new database_name: database_name, client: @client, blacklisted_tables: @blacklisted_tables
        database.export!( into_bucket: @export_bucket )
      end
    end

    def database_names
      @database_names ||= @client.query( "SHOW DATABASES" )
                            .map do |db|
                              db[ "Database" ]
                            end.select do | database_name |
                              database_name.match @match
      end
    end
  end
end
