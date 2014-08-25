class AddIsEnterToChat < ActiveRecord::Migration
  def change
    add_column :chats, :is_entering, :boolean
    add_index :chats, :is_entering
    add_column :chats, :is_leaving, :boolean
    add_index :chats, :is_leaving
  end
end
