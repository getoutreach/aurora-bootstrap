require "logger"
require 'rollbar'
require 'multi_json'
require "json"

module AuroraBootstrapper
  autoload :Converter, "aurora_bootstrapper/converter"
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

  Rollbar.configure do |config|
    config.access_token = ENV.fetch "ROLLBAR_TOKEN"
  end
end