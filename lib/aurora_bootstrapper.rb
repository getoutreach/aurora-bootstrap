require "json"

module AuroraBootstrapper
  autoload :Converter, "aurora_bootstrapper/converter"
  autoload :CsvParser, "aurora_bootstrapper/csv_parser"
  autoload :Database,  "aurora_bootstrapper/database"
  autoload :Exporter,  "aurora_bootstrapper/exporter"
  autoload :File,      "aurora_bootstrapper/file"
  autoload :Logger,    "aurora_bootstrapper/logger"
  autoload :Table,     "aurora_bootstrapper/table"

  ROW_DELIMITER = -'AURORA-BOOTSTRAP-EXPORT-ROW-DELIMITER'
  COL_DELIMITER = -'AURORA-BOOTSTRAP-EXPORT-COL-DELIMITER'

  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new( STDOUT )
end