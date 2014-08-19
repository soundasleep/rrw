class AddDiedAtToNpc < ActiveRecord::Migration
  def change
    add_column :npcs, :died_at, :datetime
  end
end
