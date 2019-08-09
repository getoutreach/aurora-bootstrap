$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'simplecov'
require 'dotenv'

Dotenv.load('.env.test')

SimpleCov.start do
  add_filter "/test/"
end

class PutsLogger
  [:fatal, :error, :warn, :info, :debug].each do |severity|
    define_method severity do | message, &block |
      puts message
    end
  end
end

# Greg's local services
module Gls
  # something storage
  class S2
    def get_object( bucket:, key:, range: "" )
      FileObject.new path: "#{bucket}/#{key}", range: range
    end
  end

  class FileObject
    def initialize( path:, range: "" )
      @string    = StringIO.new( File.new( path, 'r' ).read )
      @raw_range = range
    end

    def body
      self
    end

    def content_length
      @string.length
    end

    def read( &block )
      if range
        @string.read range.begin, &block
        @string.read @range.end - range.begin, &block
      else
        @string.read &block
      end
    end

    def range
      @range ||= begin
        if @raw_range.empty?
          nil
        else
          numbers = @raw_range.split('=').last.split('-').map(&:to_i)
          Range.new *numbers
        end
      end
    end
  end
end

require_relative "../lib/aurora_bootstrapper"
require "minitest/autorun"
require "mocha/minitest"
