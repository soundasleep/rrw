require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
  test "we have connections to test" do
    assert_not_equal 0, Connection.all.length || 0
  end

  # test that any 'requires deaths' is defined corectly
  Connection.where.not(:requires_death_id => nil).each do |c|
    test "connection #{c.from} to #{c.to} has a valid death target" do
      assert_not_nil c.requires_death
      assert_equal c.requires_death.space, c.from, "Blocking NPC #{c.requires_death.name} was not in #{c.from.name} but in #{c.requires_death.space.name}"
    end
  end

end
