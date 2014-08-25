class AddIsNewPlayerToChat < ActiveRecord::Migration
  def change
    add_column :chats, :is_new_player, :boolean
    add_index :chats, :is_new_player
  end
end
