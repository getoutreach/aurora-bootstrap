require "mysql2"
require "logger"

module AuroraBootstrapper
  autoload :Database, "aurora_bootstrapper/database"
  autoload :Exporter, "aurora_bootstrapper/exporter"
  autoload :Table,    "aurora_bootstrapper/table"

  ROW_DELIMITER = -' OUTREACH-AURORA-EXPORT-ROW-DELIMITER '
  COL_DELIMITER = -' OUTREACH-AURORA-EXPORT-COL-DELIMITER '

  class << self
    attr_accessor :logger
  end

  self.logger = ::Logger.new( STDOUT )
end