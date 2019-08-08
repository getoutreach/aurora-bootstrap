module AuroraBootstrapper
  class CsvParser
    def initialize( bucket:, table: )
      @bucket = bucket
      @table  = table
      @client = Aws::S3::Client.new
    end

    def part_urls
      @manifest_json[ "entries" ].map do | entry |
        entry[ "url" ]
      end
    end

    def manifest_json
      @manifest_json ||= JSON.parse( @client.get_object bucket: @out_bucket
                                                           key: "#{@table}.manifest" )
    end

    def parse
      # do we want to load all the things into memory?
      part_urls.each do | part |
    end

    def fields
      part_urls.first
    end

    def parse_csv( csv_path )

    end
  end
end