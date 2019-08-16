module AuroraBootstrapper
  class Table
    def initialize( database_name:, table_name:, client:, blacklisted_fields: [] )
      @blacklisted_fields = blacklisted_fields
      @database_name      = database_name
      @table_name         = table_name
      @client             = client
    end

    def fields
      @fields ||= @client.query("DESC #{ @database_name }.#{ @table_name }").map do | row |
        row[ "Field" ]
      end.reject do | field |
        blacklisted_field?( field )
      end
    end

    def blacklisted_field?( field )
      @blacklisted_fields.any? do | blacklisted_field |
        # blacklisted fields can be in the format of "field", "table.field" or "database.table.field"

        bl_field_name    = blacklisted_field
        bl_table_name    = @table_name
        bl_database_name = @database_name


        if blacklisted_field.match( /\/.*\// )
          regexp         = blacklisted_field.slice(1...-1)
          qualified_name = "#{@database_name}.#{@table_name}.#{field}"

          bl_field_name  = qualified_name.match( /#{regexp}/ ) ? field : false

        elsif blacklisted_field.match( /[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+/ )
          bl_database_name, bl_table_name, bl_field_name = blacklisted_field.split(".")

        elsif blacklisted_field.match( /[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+/ )
          bl_table_name, bl_field_name = blacklisted_field.split(".")
          bl_database_name             = @database_name
        end

        bl_field_name    == field &&
        bl_table_name    == @table_name &&
        bl_database_name == @database_name
      end
    end

    def fields_row
      fields.map do | field |
        "'#{field}'"
      end.join(', ')
    end

    def export!( into_bucket: )
      result = @client.query( export_statement( into_bucket: into_bucket ) )
      AuroraBootstrapper.logger.info( "Export succeeded: #{result.inspect}" )
      true
    rescue => e
      AuroraBootstrapper.logger.fatal( "Export failed: #{e}" )
      false
    end

    def export_statement( into_bucket: )
      <<~SQL
        SELECT #{ fields_row }
          UNION ALL
        SELECT #{ fields.join(', ') }
          FROM #{ @database_name }.#{ @table_name }
        INTO OUTFILE S3 '#{ into_bucket }/#{ @database_name }/#{ @table_name }'
          FIELDS TERMINATED BY '#{ AuroraBootstrapper::COL_DELIMITER }'
          LINES TERMINATED BY '#{ AuroraBootstrapper::ROW_DELIMITER }'
          MANIFEST ON
          OVERWRITE ON
      SQL
    end
  end
end
