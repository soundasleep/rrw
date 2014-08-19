class AddRespawnsToNpc < ActiveRecord::Migration
  def change
    add_column :npcs, :respawns, :integer
  end
end
