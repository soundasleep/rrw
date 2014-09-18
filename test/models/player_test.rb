require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  test "can travel" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    c = Connection.new(from: s1, to: s2)
    player.space = s1

    assert_true player.travel(c), "Should have been able to travel"
    assert_equal 0, player.problems.length
    assert_equal s2, player.space
  end

  test "can not travel when the connection is blocked by an alive NPC" do
    player = Player.new
    s1 = Space.new(name: "Space 1")
    s2 = Space.new(name: "Space 2")
    npc = Npc.new
    c = Connection.new(from: s1, to: s2)
    b = Blocker.new(npc: npc, connection: c)
    b.save()
    player.space = s1

    assert_false player.travel(c), "Should not have been able to travel"
    assert_greater_than 0, player.problems.length
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
    item_type = ItemType.new(:base_cost => 10, :item_type => "sword")
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
    item_type = ItemType.new(:base_cost => 10, :item_type => "sword")
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
    item_type = ItemType.new(:base_cost => 10, :item_type => "sword")
    npc_sell = NpcSells.new(:item_type => item_type, :npc => npc, :current_quantity => 0)

    assert_false player.has_item_type?(item_type)

    assert_false player.buy(npc_sell), "Should have been able to buy something"
    assert_equal(20, player.gold)
    assert_false player.has_item_type?(item_type)
    assert_equal 0, player.get_items(item_type).length
  end

  test "can sell something" do
    player = Player.new(:gold => 0)
    npc = Npc.new
    item_type = ItemType.new(:base_cost => 10, :item_type => "sword")
    npc_buy = NpcBuys.new(:item_type => item_type, :npc => npc)
    player_item = PlayerItem.new(:player => player, :item_type => item_type)
    player_item.save()

    assert_true player.has_item_type?(item_type)

    assert_true player.sell(npc_buy), "Should have been able to sell something"
    assert_equal(10, player.gold)
    assert_false player.has_item_type?(item_type)
  end

  test "can not sell something we don't have" do
    player = Player.new(:gold => 0)
    npc = Npc.new
    item_type = ItemType.new(:base_cost => 10, :item_type => "sword")
    npc_buy = NpcBuys.new(:item_type => item_type, :npc => npc)

    assert_false player.has_item_type?(item_type)

    assert_false player.sell(npc_buy), "Should not have been able to sell something"
    assert_equal(0, player.gold)
  end

  test "can use a health potion" do
    player = Player.new(:current_health => 10, :total_health => 20)
    item_type = ItemType.new(:item_type => "health_potion")
    player_item = PlayerItem.new(:player => player, :item_type => item_type)
    player_item.save()

    assert_true player.has_item_type?(item_type)

    assert_true player.use(player_item)

    # consumable
    assert_false player.has_item_type?(item_type)
    assert_equal 20, player.current_health
  end

  test "can use two health potions" do
    player = Player.new(:current_health => 10, :total_health => 30)
    item_type = ItemType.new(:item_type => "health_potion")
    player_item = PlayerItem.new(:player => player, :item_type => item_type, :quantity => 2)
    player_item.save()

    assert_true player.has_item_type?(item_type)

    assert_true player.use(player_item)

    # consumable
    assert_true player.has_item_type?(item_type)
    assert_equal 20, player.current_health

    assert_true player.use(player_item)

    # consumable
    assert_false player.has_item_type?(item_type)
    assert_equal 30, player.current_health
  end

  test "cannot use a weapon" do
    player = Player.new
    item_type = ItemType.new(:item_type => "sword")
    player_item = PlayerItem.new(:player => player, :item_type => item_type)
    player_item.save()

    assert_false player.use(player_item)
  end

  test "can equip a weapon" do
    player = Player.new
    item_type = ItemType.new(:item_type => "sword")
    player_item = PlayerItem.new(:player => player, :item_type => item_type)
    player_item.save()

    assert_true player.has_item_type?(item_type)
    assert_false player.has_equipped?(item_type)

    assert_true player.equip(player_item)

    assert_true player.has_equipped?(item_type)

    # we can equip it again
    assert_true player.equip(player_item)
  end

  test "can unequip a weapon" do
    player = Player.new
    item_type = ItemType.new(:item_type => "sword")
    player_item = PlayerItem.new(:player => player, :item_type => item_type, :equipped => true)
    player_item.save()

    assert_true player.has_item_type?(item_type)
    assert_true player.has_equipped?(item_type)

    assert_true player.unequip(player_item)

    assert_false player.has_equipped?(item_type)

    # we can't unequip it again
    assert_false player.unequip(player_item)
  end

end
