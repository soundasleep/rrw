class AddCanSellToNpc < ActiveRecord::Migration
  def change
    add_column :npcs, :can_sell, :boolean
    add_index :npcs, :can_sell
  end
end
