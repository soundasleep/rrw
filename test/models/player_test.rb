require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "can travel" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    c = Connection.new(from: s1, to: s2)
    player.space = s1

    assert_true player.travel(c), "Should have been able to travel"
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

  test "can attack an npc" do
    player = Player.new(:total_health => 20)
    npc = Npc.new(:total_health => 5, character_type: "mouse")

    assert_true player.attack(npc), "Should have been able to attack"
    assert_less_than 5, npc.current_health
    assert_less_than 20, player.current_health
  end

  test "cannot attack a dead npc" do
    player = Player.new(:total_health => 20)
    npc = Npc.new(:total_health => 5, :current_health => 0, character_type: "mouse")

    assert_false player.attack(npc), "Should not have been able to attack"
    assert_equal 0, npc.current_health
    assert_equal 20, player.current_health
  end

  test "can buy something" do
    player = Player.new(:total_health => 20, :gold => 20)

    npc = Npc.new
    item_type = ItemType.new(:base_cost => 10)
    npc_sell = NpcSells.new(:item_type => item_type, :npc => npc, :current_quantity => 1)

    assert_false player.has_item_type?(item_type)

    assert_true player.buy(npc_sell), "Should have been able to buy something"
    assert_equal(10, player.gold)
    assert_true player.has_item_type?(item_type)
    assert_equal 1, player.get_items(item_type).length
  end

  test "can not buy something with no gold" do
    player = Player.new(:total_health => 20, :gold => 0)

    npc = Npc.new
    item_type = ItemType.new(:base_cost => 10)
    npc_sell = NpcSells.new(:item_type => item_type, :npc => npc, :current_quantity => 1)

    assert_false player.has_item_type?(item_type)

    assert_false player.buy(npc_sell), "Should not have been able to buy something"
    assert_equal(0, player.gold)
    assert_false player.has_item_type?(item_type)
    assert_equal 0, player.get_items(item_type).length
  end

  test "can not buy something if there is no quantity" do
    player = Player.new(:total_health => 20, :gold => 20)

    npc = Npc.new
    item_type = ItemType.new(:base_cost => 10)
    npc_sell = NpcSells.new(:item_type => item_type, :npc => npc, :current_quantity => 0)

    assert_false player.has_item_type?(item_type)

    assert_false player.buy(npc_sell), "Should have been able to buy something"
    assert_equal(20, player.gold)
    assert_false player.has_item_type?(item_type)
    assert_equal 0, player.get_items(item_type).length
  end
end
