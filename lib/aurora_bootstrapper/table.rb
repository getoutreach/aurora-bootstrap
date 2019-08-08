module AuroraBootstrapper
  class Table
    def initialize( database_name:, table_name:, client: )
      @database_name = database_name
      @table_name    = table_name
      @client        = client
    end

    def fields
      @fields ||= @client.query("DESC #{ @database_name }.#{ @table_name }").map do | row |
        row[ "Field" ]
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
        INTO OUTFILE S3 '#{ into_bucket }'
          FIELDS TERMINATED BY '#{ AuroraBootstrapper::COL_DELIMITER }'
          LINES TERMINATED BY '#{ AuroraBootstrapper::ROW_DELIMITER }'
          MANIFEST ON
          OVERWRITE ON
      SQL
    end
  end
end