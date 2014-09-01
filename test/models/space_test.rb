require 'test_helper'

class SpaceTest < ActiveSupport::TestCase
  Space.all.each do |space|
    test "#{space.name} has at least one outgoing connection" do
      assert_not_equal 0, Connection.where(:from => space).length || 0
    end
  end

  Space.all.each do |space|
    test "#{space.name} has at least one incoming connection" do
      assert_not_equal 0, Connection.where(:to => space).length || 0
    end
  end
end
