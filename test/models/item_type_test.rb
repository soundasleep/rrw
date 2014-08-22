require 'test_helper'

class ItemTypeTest < ActiveSupport::TestCase
  test "we have item types to test" do
    assert_not_equal 0, ItemType.all.length || 0
  end

  # parameterised tests cf http://blog.nikhaldimann.com/2013/01/23/robust-parametrized-unit-tests-in-ruby/
  # lib/tasks/test_seed loads seeds.rb data directly into the model for us to test
  # (so we consequently ignore fixtures data)
  ItemType.all.each do |item_type|
    test "we can load item type #{item_type.item_type}" do
      assert_not_nil item_type.get_model
    end
  end

end
