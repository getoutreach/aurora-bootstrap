module AuroraBootstrapper
  class CsvParser
    def initialize( bucket:, table:, client:, csv_chunk_size: 10 )
      @bucket         = bucket
      @table          = table
      @client         = client
      @csv_chunk_size = csv_chunk_size
    end

    def read
      parts.each do | file |
        remainder      = ""

        file.number_of_parts.times do | part_number |

          chunk = file.body( part_number: part_number )

          # parse the current chunk; append any leftovers to the remainder
          rows_hash, remainder = hasherize( chunk: chunk, remainder: remainder )

          # let the caller deal with the hash
          yield rows_hash
        end
      end
    end

    def parts
      manifest_json[ "entries" ].map do | entry |
        bucket, database, table = entry[ "url" ].split('://').last.split("/")
        
        File.new( client: @client,
                  bucket: bucket,
               file_name: "#{database}/#{table}",
          csv_chunk_size: @csv_chunk_size )
      end
    end

    def manifest_json
      @manifest_json ||= JSON.parse( manifest.body )
    end

    def manifest
      @manifest ||= File.new( client: @client,
                              bucket: @bucket,
                           file_name: "#{@table}.manifest",
                      csv_chunk_size: @csv_chunk_size )
    end

    def fields
      @fields ||= begin
        # if the column list takes more than a MB, I'm becoming a corn farmer
        chunk = parts.first.body( size_in_mb: 1 )

        header_row = chunk.split( AuroraBootstrapper::ROW_DELIMITER ).first

        header_row.split( AuroraBootstrapper::COL_DELIMITER )
      end
    end


    def hasherize( chunk:, remainder: "" )
      # if there's left over columns from the previous chunk, let's prepend them
      chunk     = remainder + chunk

      # now that we have prepended the remainder, let's reset it
      remainder = ""
      
      return chunk.split( AuroraBootstrapper::ROW_DELIMITER ).each_with_object( [] ) do | csv_row, rows |
        columns = csv_row.split( AuroraBootstrapper::COL_DELIMITER )
        
        # fix weird nul representation
        columns.map!{ |val| val == '\\N' ? nil : val }

        # if the number of columns is fewer than the number of fields we have
        if columns.count < fields.count
          # we assume that they're in the next chunk, so we add them to the remainder
          remainder = csv_row
        # let's be sure not to add the headers as a row into the export
        elsif !header_row?( columns )
          # otherwise, they'll go in the current json
          rows << fields.zip( columns ).to_h
        end
      end, remainder
    end


    def header_row?( columns )
      ( fields - columns ).empty?
    end
  end
end