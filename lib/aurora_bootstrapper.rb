require "mysql2"
require "logger"
require "json"

module AuroraBootstrapper
  autoload :CsvParser, "aurora_bootstrapper/csv_parser"
  autoload :Database,  "aurora_bootstrapper/database"
  autoload :Exporter,  "aurora_bootstrapper/exporter"
  autoload :Table,     "aurora_bootstrapper/table"

  ROW_DELIMITER = -'AURORA-BOOTSTRAP-EXPORT-ROW-DELIMITER'
  COL_DELIMITER = -'AURORA-BOOTSTRAP-EXPORT-COL-DELIMITER'

  class << self
    attr_accessor :logger
  end

  self.logger = ::Logger.new( STDOUT )
end