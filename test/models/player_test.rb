require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "can travel" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    c = Connection.new(from: s1, to: s2)
    player.space = s1
    assert_true player.travel(c)
    assert_equal 0, player.errors.length
    assert_equal s2, player.space
  end

  test "can not travel when the connection is blocked by an alive NPC" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    npc = Npc.new
    c = Connection.new(from: s1, to: s2, requires_death: npc)
    player.space = s1
    assert_false player.travel(c), "Should not have been able to travel"
    assert_greater_than 0, player.errors.length
    assert_equal s1, player.space
  end
end
