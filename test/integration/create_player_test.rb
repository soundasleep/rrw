require "integration_test_helper"

class CreatePlayerTest < AbstractPlayerTest

  test "can create a new player" do
    create_player!
  end

  test "can travel and attack" do
    create_player!

    assert page.has_no_content?("Innkeeper")
    assert page.has_no_content?("#{@user.name} attacked Mouse 1 with 1d4 causing")

    click_button "Go to the inn"
    assert page.has_content?("You are currently at Inn")
    assert page.has_content?("Innkeeper")
    assert page.has_no_content?("#{@user.name} attacked Mouse 1 with 1d4 causing")

    click_button "Attack Mouse 1"
    assert page.has_content?("#{@user.name} attacked Mouse 1 with 1d4 causing")
    # the mouse may be dead
  end

  test "can unequip the starting dagger" do
    create_player!

    click_link("Inventory (1)")
    assert page.has_content?("1 x Dagger")
    assert page.has_content?("(equipped)")

    click_button "Unequip"
    assert page.has_content?("1 x Dagger")
    assert page.has_no_content?("(equipped)")

    # now if we attack the mouse, we do 1d3 damage
    click_link("Home")
    click_button "Go to the inn"
    click_button "Attack Mouse 1"
    assert page.has_content?("#{@user.name} attacked Mouse 1 with 1d3 causing")
    # the mouse may be dead
  end

  test "cannot buy things with no money" do
    create_player!
    click_button "Go to the inn"

    click_button "Buy one Health potion from Innkeeper"
    assert page.has_no_content?("You bought one Health potion from Innkeeper")
  end

  test "can buy things when we have money" do
    create_player!
    current_player.gold = 100
    current_player.save()

    click_button "Go to the inn"

    click_button "Buy one Health potion from Innkeeper"
    assert page.has_content?("You bought one Health potion from Innkeeper")

    click_link("Inventory (2)")
    assert page.has_content?("1 x Dagger")
    assert page.has_content?("1 x Health potion")

    # we have full health
    click_button "Use"
    assert page.has_content?("You used one Health potion")
    assert page.has_content?("Healed 0 health with Health potion")
  end

  test "can sell the dagger we have equipped" do
    create_player!

    click_button "Go to the inn"

    click_button "Sell one Dagger to Innkeeper"
    assert page.has_content?("You sold one Dagger to Innkeeper")

    click_link("Inventory (0)")
    assert page.has_no_content?("1 x Dagger")
  end

end
