module AuroraBootstrapper
  class Table
    def initialize( database_name:, table_name:, client: )
      @database_name = database_name
      @table_name    = table_name
      @client        = client
    end

    def fields
      @fields ||= client.query("DESC #{ @database_name }.#{ @table_name }").map do | row |
        row[ "Field" ]
      end
    end

    def fields_row
      fields.map do | field |
        "'#{field}'"
      end.join(', ')
    end

    def export!( into_bucket: )
      @client.query( export_bucket( into_bucket: into_bucket ) )
    end

    def export_statement( into_bucket: )
      <<~SQL
        SELECT #{ fields_row }
          UNION ALL
        SELECT #{ fields.join(', ') }
          FROM #{ @database_name }.#{ @table_name }
        INTO OUTFILE S3 #{ into_bucket }
          FIELDS TERMINATED BY '#{ AuroraBootstrapper::COL_DELIMITER }'
          LINES TERMINATED BY '#{ AuroraBootstrapper::COL_DELIMITER }'
          OVERWRITE ON
      SQL
    end
  end
end