$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'webmock/minitest'
require 'mocha'
require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require "aurora_bootstrapper"
require "minitest/autorun"

