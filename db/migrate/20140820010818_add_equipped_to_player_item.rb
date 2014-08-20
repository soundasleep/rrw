class AddEquippedToPlayerItem < ActiveRecord::Migration
  def change
    add_column :player_items, :equipped, :boolean
  end
end
