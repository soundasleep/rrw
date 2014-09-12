require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new(name: "Test user", provider: "testing")
    @user.save()
  end

  teardown do
    @user.destroy
  end

  test "can login" do
    # login through test method
    post_via_redirect "/sessions/test", id: @user.id
    assert_response :success

    assert_equal "/player/new", path
    assert_select "input#player_name"
  end
end
