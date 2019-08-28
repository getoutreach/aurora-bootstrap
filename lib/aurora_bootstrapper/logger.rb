require "logger"
require "rollbar"
require "multi_json"

module AuroraBootstrapper
  class Logger
    Rollbar.configure do |config|
      config.access_token = ENV.fetch( 'ROLLBAR_TOKEN' )
    end

    ROLLBAR_SEVERITY = { debug: :debug,
                          info: :info,
                          warn: :warning,
                         error: :error,
                         fatal: :critical }

    
    def initialize( output )
      @logger = ::Logger.new output
    end

    [ :fatal, :error, :warn, :info, :debug ].each do |severity|
      define_method severity do | args, &block |
        message = args[ :message ]
        error   = args[ :error ]

        @logger.send severity, "#{message}: #{error}"
        rollbar severity, message: message, error: error
      end
    end

    def rollbar( severity, error:, message: )
      rollbar_severity = ROLLBAR_SEVERITY[ severity ]

      Rollbar.send rollbar_severity, error, message
    end
  end
end