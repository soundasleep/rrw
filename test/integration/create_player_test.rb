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
    assert page.has_content?("Mouse 1 attacked #{@user.name} with 1d3 causing")
  end

end
