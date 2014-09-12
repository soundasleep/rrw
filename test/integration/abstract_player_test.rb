require "integration_test_helper"

class AbstractPlayerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new(name: "Test user", provider: "testing")
    @user.save()
  end

  teardown do
    @user.destroy
  end

  def do_login!
    # login through test method
    visit "/sessions/test?id=#{@user.id}"
    assert_equal "/player/new", current_path
  end

  def create_player!
    do_login!

    visit "/player/new"
    assert page.has_field?("Name", with: @user.name)
    click_button "Start playing"

    assert page.has_content?("You are currently at Home")
  end
end
