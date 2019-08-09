module AuroraBootstrapper
  class CsvParser
    class << self
      attr_accessor :csv_chunk_size
    end

    MB_IN_BYTES = 1048576

    # 10MB seems like a reasonable chunk size
    self.csv_chunk_size = 10

    def initialize( bucket:, table:, client: )
      @bucket   = bucket
      @table    = table
      @client   = client
    end

    def read
      parts.each do | part |
        file           = part[ :file ]
        remainder      = ""
        content_length = @client.get_object( bucket: @bucket,
                                                key: file,
                                              range: range_header( number: 0, size_in_mb: 1/512 ) ).content_length

        parts_number = ( content_length * 1.0 / ( MB_IN_BYTES * self.class.csv_chunk_size ) ).ceil

        parts_number.times do | part_number |
          chunk = file_body(   file: file,
                              range: range_header( number: part_number ) )

          # parse the current chunk; append any leftovers to the remainder
          rows_hash, remainder = hasherize( chunk: chunk, remainder: remainder )

          # let the caller deal with the hash
          yield rows_hash
        end
      end
    end

    def parts
      manifest_json[ "entries" ].map do | entry |
        bucket, database, table = entry[ "url" ].split('//').last.split('/')
        { bucket: bucket,
            file: "#{database}/#{table}" }
      end
    end

    def manifest_json
      @manifest_json ||= JSON.parse( file_body( file: "#{@table}.manifest" ) )
    end

    def fields
      @fields ||= begin
        part   = parts.first

        file   = part[ :file ]

        # if the column list takes more than 2MB, I'm becoming a corn farmer
        range  = range_header number: 0, size_in_mb: 2

        header_chunk = file_body(   file: file,
                                   range: range )

        header_chunk.split( AuroraBootstrapper::ROW_DELIMITER ).first.
                     split( AuroraBootstrapper::COL_DELIMITER )
      end
    end

    def range_header( number:, size_in_mb: self.class.csv_chunk_size )
      start = number * size_in_mb * MB_IN_BYTES
      stop  = start + ( size_in_mb * MB_IN_BYTES ) - 1

      "bytes=#{start}-#{stop}"
    end

    def file_body( file:, bucket: @bucket, range: "" )
      @client.get_object( bucket: bucket,
                             key: file,
                           range: range ).body.read
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
        else
          # otherwise, they'll go in the current json
          rows << fields.zip( columns ).to_h
        end
      end, remainder
    end
  end
end