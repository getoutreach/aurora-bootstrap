module AuroraBootstrapper
  class Converter
    def initialize( out_of_csv_bucket:, into_json_bucket:, tables: )
      @out_bucket = out_of_csv_bucket
      @in_bucket  = into_json_bucket
      @tables     = tables
      @client     = Aws::S3.new
    end

    def convert
      tables.each do | table |
        CsvParser.new( bucket: @out_bucket, table: table, client: @client ).read do | rows |
          write rows.to_json
        end
      end
    end


    def write( payload )

    end
  end
end