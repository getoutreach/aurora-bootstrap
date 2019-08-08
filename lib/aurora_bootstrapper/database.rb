module AuroraBootstrapper
  class Database
    def initialize( database_name:, client:, blacklisted_tables: [] )
      @database_name      = database_name
      @blacklisted_tables = blacklisted_tables
      @client             = client
    end

    def table_names
      @table_names ||= @client.query( "SHOW TABLES IN #{@database_name}" ).map do | row |
        row[ "Tables_in_#{@database_name}" ]
      end.reject do | table_name |
        blacklisted_table?( table_name )
      end
    end

    def export!( into_bucket )
      table_names.all? do | table_name |
        table = Table.new database_name: @database_name, table_name: table_name, client: @client
        table.export!( into_bucket: into_bucket )
      end
    end

    def blacklisted_table?( table_name )
      @blacklisted_tables.any? do | blacklisted_table |
        # blacklisted tables can be in the format of "table" or "database.table"
        
        # the table name will always be the last thing in the split array
        bl_table_name    = blacklisted_table.split(".").last

        # if the blacklisted table has a db specifier ('.'' in the name)
        bl_database_name = blacklisted_table.match( /\./ ) ?
                              # then we take the fist part of the name
                              blacklisted_table.split(".").first :
                              # otherwise it will be true for every db
                              # we take the current db name to ensure a match
                              @database_name
        
        bl_table_name    == table_name &&
        bl_database_name == @database_name
      end
    end
  end
end
