module AuroraBootstrapper
  class Database
    attr_accessor :name

    def initialize( database_name:, client: )
      @name   = database_name
      @client = client
    end

    def table_names
      client.query( "SHOW TABLES IN #{name}" ).map do | row |
        row[ "Tables_in_#{name}" ]
      end
    end

    def export!( into_bucket)
      table_names.each do | table_name |
        table = Table.new database_name: database_name, table_name: table_name, client: client
        table.export!( into_bucket: export_bucket )
      end
    end
  end
end
