class AddTypeToNpc < ActiveRecord::Migration
  def change
    add_column :npcs, :character_type, :string
    add_index :npcs, :character_type
  end
end
