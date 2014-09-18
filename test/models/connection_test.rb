require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
  test "we have connections to test" do
    assert_not_equal 0, Connection.all.length || 0
  end

end
