require 'test_helper'

class ChatTest < ActiveSupport::TestCase
  test "can get json for chats" do
    chat = Chat.new(:text => "hello, world", :is_entering => true)
    json = chat.to_json

    assert_not_nil json
    assert_equal chat.text, json[:text]
    assert_equal "is-entering", json[:classes]
    assert_equal true, json[:is_entering]
    assert_equal false, json[:is_leaving]
    assert_not_nil json[:render_text]
    assert_not_nil json[:render_time]
  end

end
