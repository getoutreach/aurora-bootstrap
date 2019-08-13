module AuroraBootstrapper
  class Converter
    def initialize( out_of_csv_bucket:, into_json_bucket:, tables:, client: )
      @out_of_csv_bucket = out_of_csv_bucket
      @into_json_bucket  = into_json_bucket
      @tables            = tables.split(",")
      @client            = client
    end

    def convert!
      @tables.each do | table |
        begin
          # convert from database.table to database/table notation
          table      = table.gsub ".", "/"
          chunk_part = 0
          CsvParser.new( bucket: @out_of_csv_bucket, table: table, client: @client ).read do | rows |
            write payload: rows.to_json, name: "#{table}.#{chunk_part}.json"
            chunk_part += 1
          end
        rescue => e
          AuroraBootstrapper.logger.error e
          Rollbar.error(e)
        end
      end
    end


    def write( payload:, name: )
      AuroraBootstrapper.logger.info "Writing to #{@into_json_bucket}/#{name}"
      @client.put_object( acl: "authenticated-read", 
                         body: payload, 
                       bucket: @into_json_bucket, 
                          key: name )
    end
  end
end