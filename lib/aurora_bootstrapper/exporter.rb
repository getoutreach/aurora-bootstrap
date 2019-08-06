module AuroraBootstrapper
  class Exporter
    attr_reader :client

    def initialize( db_host:, db_user:, db_pass:, prefix:, export_bucket: )
      @db_host       = db_host
      @db_user       = db_user
      @db_pass       = db_pass
      @match         = "#{prefix}.*"
      @export_bucket = export_bucket
    end

    def connect!
      @client  = Mysql2::Client.new(     host: db_host,
                                     username: db_user,
                                     password: db_pass)
    end

    def export!
      database_names.each do | database_name |
        database = Database.new database_name: database_name, client: @client
        database.export!( into_bucket: @export_bucket )
      end
    end

    def database_names
      @databases ||= client.query( "SHOW DATABASES" )
                            .map do |db|
                              db[ "Database" ]
                            end.select do | database_name |
                              database_name.match @match
      end
    end
  end
end
