module AuroraBootstrapper
  class Converter
    def initialize( out_of_csv_bucket:, into_json_bucket:, table: )
      @out_bucket = out_of_csv_bucket
      @in_bucket  = into_json_bucket
      @table      = table
      @client     = Aws::S3::Client.new
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

    def convert
      part_urls.each do | url |

  end
end