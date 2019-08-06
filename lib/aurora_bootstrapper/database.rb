module AuroraBootstrapper
  class Database
    def initialize( database_name:, client: )
      @database_name = database_name
      @client        = client
    end

    def table_names
      client.query( "SHOW TABLES IN #{@database_name}" ).map do | row |
        row[ "Tables_in_#{@database_name}" ]
      end
    end

    def export!( into_bucket )
      table_names.each do | table_name |
        table = Table.new database_name: @database_name, table_name: table_name, client: @client
        table.export!( into_bucket: into_bucket )
      end
    end
  end
end
