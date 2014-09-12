require "integration_test_helper"

class PlayerHelperTests < AbstractPlayerTest

  test "we can access a Player when creating a player" do
    create_player!
    assert_not_nil current_player
    assert_equal 0, current_player.gold
  end

  test "we can manually modify player attributes" do
    create_player!
    current_player.gold = 100
    current_player.save()
    assert_equal 100, current_player.gold
  end

end
