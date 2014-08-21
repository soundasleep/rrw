class AddCanBuyToNpc < ActiveRecord::Migration
  def change
    add_column :npcs, :can_buy, :boolean
    add_index :npcs, :can_buy
  end
end
