require 'test_helper'

class NpcTest < ActiveSupport::TestCase
  test "we have npcs to test" do
    assert_not_equal 0, Npc.all.length || 0
  end

  # we need to convert ActiveRelation to an Array because ActiveRelation#uniq
  # is completely different from Enumerable#uniq
  Npc.all.to_a.uniq { |u| u.character_type }.each do |npc|
    test "we can load npc #{npc.character_type}" do
      assert_not_nil npc.get_model
    end
  end

  test "we have at least one NPC that buys" do
    assert_not_equal 0, Npc.where(:can_buy => true).length || 0
  end

  test "we have at least one NPC that sells" do
    assert_not_equal 0, Npc.where(:can_sell => true).length || 0
  end

  test "a default Npc is not dead" do
    assert_not_equal 0, Npc.new().current_health
    assert_not_equal 0, Npc.new().total_health
  end

end
