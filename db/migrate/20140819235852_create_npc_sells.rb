class CreateNpcSells < ActiveRecord::Migration
  def change
    create_table :npc_sells do |t|
      t.references :npc, index: true
      t.references :item_type, index: true
      t.integer :current_quantity
      t.integer :max_quantity
      t.integer :respawns

      t.timestamps
    end
  end
end
