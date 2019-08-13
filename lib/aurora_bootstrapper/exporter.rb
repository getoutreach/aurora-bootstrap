require 'mysql2'

module AuroraBootstrapper
  class Exporter
    attr_reader :client

    def initialize( client:, prefix: "", export_bucket:, blacklisted_tables: "" )
      @match              = "#{prefix}.*"
      @export_bucket      = export_bucket
      @blacklisted_tables = blacklisted_tables.split(",")
      @client             = client
    end

    def export!
      database_names.all? do | database_name |
        begin
          database = Database.new database_name: database_name, client: @client, blacklisted_tables: @blacklisted_tables
          database.export! into_bucket: @export_bucket
        rescue => e
          AuroraBootstrapper.logger.error message: "Error in database #{database_name}", error: e
        end
      end
    end

    def database_names
      @database_names ||= @client.query( "SHOW DATABASES" )
                            .map do |db|
                              db[ "Database" ]
                            end.select do | database_name |
                              database_name.match @match
      end
    rescue => e
      AuroraBootstrapper.logger.fatal message: "Error getting databases", error: e
      []
    end
  end
end
