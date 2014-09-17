require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "can travel" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    c = Connection.new(from: s1, to: s2)
    player.space = s1
    player.travel! c
    assert_equal s2, player.space
  end

  test "can not travel when the connection is blocked by an alive NPC" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    npc = Npc.new
    c = Connection.new(from: s1, to: s2, requires_death: npc)
    player.space = s1
    begin
      player.travel! c
      fail("Should have not been able to travel")
    rescue WorldError
      # success
    end
    assert_equal s1, player.space
  end
end
