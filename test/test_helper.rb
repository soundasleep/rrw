ENV["RAILS_ENV"] ||= "test"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_true(test, message="Expected: true. Actual: #{test}")
    assert_equal true, test, message
  end

  def assert_false(test, message="Expected: false. Actual: #{test}")
    assert_equal false, test, message
  end

  def assert_greater_than(expected, actual, message = "Expected #{actual} to be greater than #{expected}")
    assert_operator actual, :>, expected
  end

  def assert_less_than(expected, actual, message = "Expected #{actual} to be less than #{expected}")
    assert_operator actual, :<, expected
  end
end
