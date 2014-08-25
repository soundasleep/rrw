class AddIsDeathToChat < ActiveRecord::Migration
  def change
    add_column :chats, :is_death, :boolean
    add_index :chats, :is_death
  end
end
