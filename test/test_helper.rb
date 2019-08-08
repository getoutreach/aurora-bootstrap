$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'simplecov'
require 'dotenv'

Dotenv.load('.env.test')

SimpleCov.start do
  add_filter "/test/"
end

require_relative "../lib/aurora_bootstrapper"
require "minitest/autorun"
require "mocha/minitest"
